
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