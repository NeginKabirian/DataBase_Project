
IF OBJECT_ID('Library.CreateLibraryMemberFromStudent', 'P') IS NOT NULL
    DROP PROCEDURE Library.CreateLibraryMemberFromStudent;
GO

CREATE PROCEDURE Library.CreateLibraryMemberFromStudent
    @StudentID INT,
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100)
AS
BEGIN 
	SET NOCOUNT ON;
	DECLARE @DefaultActiveStatusID INT;
    DECLARE @GeneratedLibraryCardNumber VARCHAR(50);
    DECLARE @LogUserID NVARCHAR(128) = 'SystemTrigger_Edu';

	SELECT @DefaultActiveStatusID = AccountStatusID FROM 
	Library.MemberAccountStatuses WHERE TRIM(StatusName) = 'Active';

	IF @DefaultActiveStatusID IS NULL
	BEGIN
		RAISERROR ('Default "Active" status not found in Library.MemberAccountStatuses. Cannot create library member.', 16, 1);

		INSERT INTO Library.LibraryLog (EventType, Description, UserID) VALUES 
		('MemberAccountCreationFailed', 'Failed to find "Active" status for EduStudentID: '
		+ CAST(@StudentID AS VARCHAR), @LogUserID);

		RETURN;
    END

	SET @GeneratedLibraryCardNumber = 'LIB-' + REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', '');

	IF NOT EXISTS (SELECT 1 FROM Library.LibraryMembers WHERE StudentID = @StudentID)
	BEGIN
		BEGIN TRY

		INSERT INTO Library.LibraryMembers (StudentID, LibraryCardNumber, RegistrationDate, AccountStatusID, Notes)
            VALUES (@StudentID, @GeneratedLibraryCardNumber, GETDATE(), @DefaultActiveStatusID, 'Auto-created from Education system for ' + @FirstName + ' ' + @LastName + '.');

		DECLARE @NewMemberID INT = SCOPE_IDENTITY();

            INSERT INTO Library.LibraryLog (EventType, Description, AffectedTable, AffectedRecordID, UserID) VALUES 
			('MemberAccountCreated', 'Lib account for ' + @FirstName + ' ' + @LastName + ' (EduStudentID: ' + CAST(@StudentID AS VARCHAR) + ')', 
			'Library.LibraryMembers', CAST(@NewMemberID AS VARCHAR), @LogUserID);

        END TRY
		BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
            INSERT INTO Library.LibraryLog (EventType, Description, UserID) VALUES ('MemberAccountCreationFailed', 'Failed creation for EduStudentID: ' + CAST(@StudentID AS VARCHAR) + '. Error: ' + @ErrorMessage, @LogUserID);
        END CATCH
    END
END;
GO


IF OBJECT_ID('Education.RegisterStudent', 'P') IS NOT NULL
    DROP PROCEDURE Education.RegisterStudent;
GO

CREATE PROCEDURE Education.RegisterStudent
    @NationalID VARCHAR(20),
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @MajorID INT,
    @DateOfBirth DATE = NULL,
    @Email VARCHAR(255) = NULL,
    @PhoneNumber VARCHAR(20) = NULL,
    @RegisteredByUserID NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StudentStatusID INT;
    DECLARE @NewStudentID INT;
    DECLARE @LogUserID NVARCHAR(128) = ISNULL(@RegisteredByUserID, SUSER_SNAME());

	IF NOT EXISTS (SELECT 1 FROM Education.Majors WHERE MajorID = @MajorID)
    BEGIN
        RAISERROR('Invalid MajorID provided.', 16, 1);
        RETURN -1;
    END

	SELECT @StudentStatusID = StudentStatusID FROM Education.StudentStatuses WHERE TRIM(StatusName) = 'Active';
    IF @StudentStatusID IS NULL
    BEGIN
         RAISERROR('Default "Active" student status not found in lookup table.', 16, 1);
         RETURN -2;
    END

	BEGIN TRY
        -- Attempt to insert the student. The INSTEAD OF trigger will handle validation.
        INSERT INTO Education.Students (NationalID, FirstName, LastName, DateOfBirth, EnrollmentDate, MajorID, StudentStatusID, Email, PhoneNumber)
        VALUES (@NationalID, @FirstName, @LastName, @DateOfBirth, GETDATE(), @MajorID, @StudentStatusID, @Email, @PhoneNumber);

		SELECT @NewStudentID = StudentID FROM Education.Students WHERE NationalID = @NationalID;

        IF @NewStudentID IS NOT NULL
        BEGIN
            PRINT 'Student registered successfully. New StudentID: ' + CAST(@NewStudentID AS VARCHAR);
            INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
            VALUES ('StudentRegistered', 'New student registered: ' + @FirstName + ' ' + @LastName, 'Education.Students', CAST(@NewStudentID AS VARCHAR), @LogUserID);
            SELECT @NewStudentID AS NewStudentID;
			RETURN 0; -- Success
        END
        ELSE
        BEGIN
            RAISERROR('Student registration failed. Student record not found after insert attempt.', 16, 1);
            RETURN -3;
        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        INSERT INTO Education.EducationLog (EventType, Description, UserID)
        VALUES ('StudentRegistrationFailed', 'Failed to register student NationalID: ' + @NationalID + '. Error: ' + @ErrorMessage, @LogUserID);
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -4;
    END CATCH
END;
GO

IF OBJECT_ID('Education.EnrollStudentInCourse', 'P') IS NOT NULL
    DROP PROCEDURE Education.EnrollStudentInCourse;
GO

CREATE PROCEDURE Education.EnrollStudentInCourse
    @StudentID INT,
    @OfferedCourseID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogUserID NVARCHAR(128) = SUSER_SNAME(); -- Or get from context_info if passed from app


    --  Check if the student and offered course exist
    IF NOT EXISTS (SELECT 1 FROM Education.Students WHERE StudentID = @StudentID)
    BEGIN
        RAISERROR('Student with ID %d does not exist.', 16, 1, @StudentID);
        RETURN -1;
    END

    IF NOT EXISTS (SELECT 1 FROM Education.OfferedCourses WHERE OfferedCourseID = @OfferedCourseID)
    BEGIN
        RAISERROR('Offered course with ID %d does not exist.', 16, 1, @OfferedCourseID);
        RETURN -2;
    END

    --Check if student is already enrolled in this course
    IF EXISTS (SELECT 1 FROM Education.Enrollments WHERE StudentID = @StudentID AND OfferedCourseID = @OfferedCourseID)
    BEGIN
        RAISERROR('You are already enrolled in this course.', 16, 1);
        RETURN -3;
    END

    -- Check for available capacity
    DECLARE @AvailableCapacity INT = Education.GetOfferedCourseAvailableCapacity(@OfferedCourseID);
    IF @AvailableCapacity <= 0
    BEGIN
        RAISERROR('This course offering is full. No available capacity.', 16, 1);
        RETURN -4;
    END

    --  Check if prerequisites are met
    DECLARE @CourseID INT = (SELECT CourseID FROM Education.OfferedCourses WHERE OfferedCourseID = @OfferedCourseID);
    IF (Education.CheckCoursePrerequisitesMet(@StudentID, @CourseID) = 0)
    BEGIN
        RAISERROR('Prerequisites for this course have not been met.', 16, 1);
        RETURN -5;
    end

	BEGIN TRY
        DECLARE @EnrolledStatusID INT = (SELECT EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE TRIM(StatusName) = 'Enrolled');
        IF @EnrolledStatusID IS NULL
        BEGIN
            RAISERROR('Default "Enrolled" status not found in lookup table.', 16, 1);
            RETURN -99;
        END

        INSERT INTO Education.Enrollments (StudentID, OfferedCourseID, EnrollmentDate, EnrollmentStatusID)
        VALUES (@StudentID, @OfferedCourseID, GETDATE(), @EnrolledStatusID);

        DECLARE @NewEnrollmentID INT = SCOPE_IDENTITY();
        PRINT 'Enrollment successful! Enrollment ID: ' + CAST(@NewEnrollmentID AS VARCHAR);

       
        INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES ('CourseEnrolled',
                'Student ID ' + CAST(@StudentID AS VARCHAR) + ' enrolled in OfferedCourse ID ' + CAST(@OfferedCourseID AS VARCHAR),
                'Education.Enrollments',
                CAST(@NewEnrollmentID AS VARCHAR),
                @LogUserID);

        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        INSERT INTO Education.EducationLog (EventType, Description, UserID)
        VALUES ('CourseEnrollmentFailed',
                'Failed to enroll Student ID ' + CAST(@StudentID AS VARCHAR) + ' in OfferedCourse ID ' + CAST(@OfferedCourseID AS VARCHAR) + '. Error: ' + @ErrorMessage,
                @LogUserID);
        RAISERROR(@ErrorMessage, 16, 1); 
        RETURN -100;
    END CATCH
END;
GO