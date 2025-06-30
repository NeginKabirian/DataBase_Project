USE Database_project;
GO

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

		INSERT INTO Library.LibraryLog (EventType, Description, UserID) VALUES 
		('MemberAccountCreationFailed', 'Failed to find "Active" status for EduStudentID: '
		+ CAST(@StudentID AS VARCHAR), @LogUserID);

		RAISERROR ('Default "Active" status not found in Library.MemberAccountStatuses. Cannot create library member.', 16, 1);
		RETURN;
    END

	SET @GeneratedLibraryCardNumber = 'LIB-' + REPLACE(CAST(NEWID() AS VARCHAR(36)), '-', '');

	IF NOT EXISTS (SELECT 1 FROM Library.LibraryMembers WHERE StudentID = @StudentID)
	BEGIN
		BEGIN TRY

		INSERT INTO Library.LibraryMembers (StudentID, LibraryCardNumber, RegistrationDate, AccountStatusID, Notes)
            VALUES (@StudentID, @GeneratedLibraryCardNumber, GETDATE(), @DefaultActiveStatusID, 'Auto-created from Education system for ' + @FirstName + ' ' + @LastName + '.');


        END TRY
		BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
            INSERT INTO Library.LibraryLog (EventType, Description, UserID) VALUES ('MemberAccountCreationFailed', 'Failed creation for EduStudentID: ' + CAST(@StudentID AS VARCHAR) + '. Error: ' + @ErrorMessage, @LogUserID);
        END CATCH
    END
END;
GO



IF OBJECT_ID('Education.RecordStudentGrade', 'P') IS NOT NULL
    DROP PROCEDURE Education.RecordStudentGrade;
GO

CREATE PROCEDURE Education.RecordStudentGrade
    @EnrollmentID INT,
    @Grade NVARCHAR(10),
    @GradedByUserID NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogUserID NVARCHAR(128) = ISNULL(@GradedByUserID, SUSER_SNAME());
    DECLARE @PassedStatusID INT, @FailedStatusID INT, @NewStatusID INT;

    -- Get status IDs
    SELECT @PassedStatusID = EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE TRIM(StatusName) = 'Passed';
    SELECT @FailedStatusID = EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE TRIM(StatusName) = 'Failed';

    IF @PassedStatusID IS NULL OR @FailedStatusID IS NULL
    BEGIN
        RAISERROR('Lookup statuses "Passed" or "Failed" not found.', 16, 1);
        RETURN;
    END


    IF TRY_CAST(@Grade AS DECIMAL(4,2)) >= 10.00
    BEGIN
        SET @NewStatusID = @PassedStatusID;
    END
    ELSE
    BEGIN
        SET @NewStatusID = @FailedStatusID;
    END

    BEGIN TRY
        
        UPDATE Education.Enrollments
        SET
            Grade = @Grade,
            EnrollmentStatusID = @NewStatusID
        WHERE
            EnrollmentID = @EnrollmentID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Enrollment with ID %d not found.', 16, 1, @EnrollmentID);
            RETURN;
        END

        PRINT 'Grade recorded successfully for EnrollmentID: ' + CAST(@EnrollmentID AS VARCHAR);

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES ('GradeRecordFailed', 'Failed to record grade for EnrollmentID ' + CAST(@EnrollmentID AS VARCHAR) + '. Error: ' + @ErrorMessage, 'Education.Enrollments', @EnrollmentID, @LogUserID);
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

IF OBJECT_ID('Education.UpdateStudentMajor', 'P') IS NOT NULL
    DROP PROCEDURE Education.UpdateStudentMajor;
GO

CREATE PROCEDURE Education.UpdateStudentMajor
    @StudentID INT,
    @NewMajorID INT,
    @UpdatedByUserID NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogUserID NVARCHAR(128) = ISNULL(@UpdatedByUserID, SUSER_SNAME());

    -- Validate that the new major exists
    IF NOT EXISTS (SELECT 1 FROM Education.Majors WHERE MajorID = @NewMajorID)
    BEGIN
        RAISERROR('New MajorID %d does not exist.', 16, 1, @NewMajorID);
        RETURN;
    END

    BEGIN TRY
        UPDATE Education.Students
        SET MajorID = @NewMajorID
        WHERE StudentID = @StudentID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Student with ID %d not found.', 16, 1, @StudentID);
            RETURN;
        END

        PRINT 'Student''s major updated successfully.';

     
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES ('MajorUpdateFailed', 'Failed to update major for StudentID ' + CAST(@StudentID AS VARCHAR) + '. Error: ' + @ErrorMessage, 'Education.Students', @StudentID, @LogUserID);
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


IF OBJECT_ID('Education.UpdateStudentStatus', 'P') IS NOT NULL
    DROP PROCEDURE Education.UpdateStudentStatus;
GO

CREATE PROCEDURE Education.UpdateStudentStatus
    @StudentID INT,
    @NewStatusName NVARCHAR(50),
    @ProcessedByUserID NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @LogUserID NVARCHAR(128) = ISNULL(@ProcessedByUserID, SUSER_SNAME());
    DECLARE @NewStatusID INT;

  
    SELECT @NewStatusID = StudentStatusID
    FROM Education.StudentStatuses
    WHERE TRIM(StatusName) = TRIM(@NewStatusName);

    IF @NewStatusID IS NULL
    BEGIN
        RAISERROR('The status "%s" was not found in Education.StudentStatuses.', 16, 1, @NewStatusName);
        RETURN;
    END

    BEGIN TRY
      
        UPDATE Education.Students
        SET StudentStatusID = @NewStatusID
        WHERE StudentID = @StudentID;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Student with ID %d not found.', 16, 1, @StudentID);
            RETURN;
        END

        PRINT 'Student status for StudentID ' + CAST(@StudentID AS VARCHAR) + ' successfully updated to "' + @NewStatusName + '".';

   
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
       
        INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES ('StudentStatusUpdateFailed', 'Failed to update status for StudentID ' + CAST(@StudentID AS VARCHAR) + ' to "' + @NewStatusName + '". Error: ' + @ErrorMessage, 'Education.Students', @StudentID, @LogUserID);
       
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
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
    DECLARE @LogUserID NVARCHAR(128) = SUSER_SNAME(); 


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

IF OBJECT_ID('Education.SuggestCoursesForStudent', 'P') IS NOT NULL
    DROP PROCEDURE Education.SuggestCoursesForStudent;
GO

CREATE PROCEDURE Education.SuggestCoursesForStudent
    @StudentID INT,
    @TargetSemesterID INT
AS
BEGIN
    SET NOCOUNT ON;

	 DECLARE @MajorID INT;
    DECLARE @PassedStatusID INT;

    
    SELECT @MajorID = MajorID FROM Education.Students WHERE StudentID = @StudentID;
    IF @MajorID IS NULL
    BEGIN
        RAISERROR('Student with ID %d not found.', 16, 1, @StudentID);
        RETURN;
    END

	SELECT @PassedStatusID = EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE TRIM(StatusName) = 'Passed';
    IF @PassedStatusID IS NULL
    BEGIN
        RAISERROR('Lookup value for "Passed" status not found in EnrollmentStatuses.', 16, 1);
        RETURN;
    END
	
	DECLARE @AllMajorCourses TABLE (CourseID INT PRIMARY KEY);
    DECLARE @PassedCourses TABLE (CourseID INT PRIMARY KEY);
    DECLARE @RemainingCourses TABLE (CourseID INT PRIMARY KEY);
    DECLARE @EligibleCourses TABLE (CourseID INT PRIMARY KEY);
	-- Get all courses required for the student's major
	INSERT INTO @AllMajorCourses (CourseID)
    SELECT CourseID
    FROM Education.Curriculum
    WHERE MajorID = @MajorID;
	-- Get all courses the student has already passed
	INSERT INTO @PassedCourses (CourseID)
    SELECT DISTINCT OC.CourseID
    FROM Education.Enrollments E
    JOIN Education.OfferedCourses OC ON E.OfferedCourseID = OC.OfferedCourseID
    WHERE E.StudentID = @StudentID AND E.EnrollmentStatusID = @PassedStatusID;
	--Determine remaining courses by removing passed courses
	INSERT INTO @RemainingCourses (CourseID)
    SELECT CourseID FROM @AllMajorCourses
    EXCEPT
    SELECT CourseID FROM @PassedCourses;

	-- Filter remaining courses by checking prerequisites
    -- Only keep courses for which the student has met all prerequisites.

	INSERT INTO @EligibleCourses (CourseID)
    SELECT R.CourseID
    FROM @RemainingCourses R
    WHERE Education.CheckCoursePrerequisitesMet(@StudentID, R.CourseID) = 1;

	-- Find which eligible courses are offered in the target semester
    -- and present them in a prioritized order.

	SELECT
        C.CourseCode,
        C.CourseName,
        C.Credits,
        CUR.SuggestedTerm,
        CUR.Priority,
        OC.OfferedCourseID, 
        P.FirstName + ' ' + P.LastName AS ProfessorName,
        OC.ScheduleInfo
    FROM
        @EligibleCourses EC
    JOIN
        Education.OfferedCourses OC ON EC.CourseID = OC.CourseID 
    JOIN
        Education.Courses C ON OC.CourseID = C.CourseID 
    JOIN
        Education.Curriculum CUR ON EC.CourseID = CUR.CourseID AND CUR.MajorID = @MajorID 
    LEFT JOIN
        Education.Professors P ON OC.ProfessorID = P.ProfessorID 
    WHERE
        OC.SemesterID = @TargetSemesterID
        AND Education.GetOfferedCourseAvailableCapacity(OC.OfferedCourseID) > 0 
    ORDER BY
        CUR.SuggestedTerm ASC,
        CUR.Priority ASC,   
        C.CourseName ASC;      

END;

-------------------------------------------------------------------------------------------------------------------
--Library
IF OBJECT_ID('Library.RecommendBooksToStudent', 'P') IS NOT NULL
    DROP PROCEDURE Library.RecommendBooksToStudent;
GO
CREATE PROCEDURE Library.RecommendBooksToStudent
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;

    WITH CurrentStudentBooks AS (
        SELECT DISTINCT BC.BookID
        FROM Library.Loans L
        JOIN Library.BookCopies BC ON L.CopyID = BC.CopyID
        JOIN Library.LibraryMembers LM ON LM.MemberID = L.MemberID
        WHERE LM.StudentID = @StudentID
    ),

 
    LoanBookMember AS (
        SELECT DISTINCT BC.BookID, LM.StudentID
        FROM Library.Loans L
        JOIN Library.BookCopies BC ON L.CopyID = BC.CopyID
        JOIN Library.LibraryMembers LM ON LM.MemberID = L.MemberID
    ),

    
    SimilarStudents AS (
        SELECT LBM.StudentID
        FROM LoanBookMember LBM
        JOIN CurrentStudentBooks CSB ON LBM.BookID = CSB.BookID
        WHERE LBM.StudentID != @StudentID
        GROUP BY LBM.StudentID
        HAVING COUNT(DISTINCT LBM.BookID) >= 2
    ),

 
    RecommendedBooks AS (
        SELECT LBM.BookID
        FROM LoanBookMember LBM
        JOIN SimilarStudents SS ON LBM.StudentID = SS.StudentID
        WHERE LBM.BookID NOT IN (SELECT BookID FROM CurrentStudentBooks)
    )

    SELECT TOP 3 B.BookID, B.Title, COUNT(*) AS Frequency
    FROM RecommendedBooks RB
    JOIN Library.Books B ON RB.BookID = B.BookID
    GROUP BY B.BookID, B.Title
    ORDER BY Frequency DESC;
END

IF OBJECT_ID('Library.BorrowBook', 'P') IS NOT NULL
    DROP PROCEDURE Library.BorrowBook;
GO

CREATE PROCEDURE [Library].[BorrowBook]
    @MemberID INT,
    @CopyID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
       
        DECLARE @ActiveMemberStatusID INT, @AvailableCopyStatusID INT;

        SELECT @ActiveMemberStatusID = AccountStatusID 
        FROM Library.MemberAccountStatuses 
        WHERE StatusName = 'Active';

        SELECT @AvailableCopyStatusID = CopyStatusID 
        FROM Library.BookCopyStatuses 
        WHERE StatusName = 'Available';
        
 
        IF @ActiveMemberStatusID IS NULL OR @AvailableCopyStatusID IS NULL
        BEGIN
            RAISERROR('System configuration is incomplete. The required "Active" or "Available" statuses were not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- --- Step 2: Validate the member and the book copy ---
        DECLARE @CurrentMemberStatusID INT, @CurrentCopyStatusID INT;

        -- Check the member's current status
        SELECT @CurrentMemberStatusID = AccountStatusID 
        FROM Library.LibraryMembers 
        WHERE MemberID = @MemberID;

        IF @CurrentMemberStatusID IS NULL
        BEGIN
            RAISERROR('The specified MemberID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @CurrentMemberStatusID <> @ActiveMemberStatusID
        BEGIN
            RAISERROR('The member''s account is not "Active". Borrowing is not permitted.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Check the book copy's current status
        SELECT @CurrentCopyStatusID = CopyStatusID 
        FROM Library.BookCopies 
        WHERE CopyID = @CopyID;

        IF @CurrentCopyStatusID IS NULL
        BEGIN
            RAISERROR('The specified CopyID does not exist.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @CurrentCopyStatusID <> @AvailableCopyStatusID
        BEGIN
            RAISERROR('This book copy is not "Available" for loan. It may be already borrowed or under maintenance.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- --- Step 3: Insert the new loan record ---
        -- Set the due date for 14 days from today.
        DECLARE @DueDate DATETIME = DATEADD(day, 14, GETDATE());

        INSERT INTO [Library].[Loans] (CopyID, MemberID, LoanDate, DueDate)
        VALUES (@CopyID, @MemberID, GETDATE(), @DueDate);
        
        -- Get the ID of the newly created loan record for logging purposes.
        DECLARE @NewLoanID BIGINT = SCOPE_IDENTITY();
		DECLARE @UserID NVARCHAR(128) = SUSER_SNAME();
        -- --- Step 4: Log the event in the LibraryLog table ---
        INSERT INTO [Library].[LibraryLog] (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES (
            'Book Borrowed',
            'Book copy with ID ' + CAST(@CopyID AS VARCHAR(10)) + N' was borrowed by member with ID ' + CAST(@MemberID AS VARCHAR(10)) + N'.',
            'Library.Loans',
            CAST(@NewLoanID AS VARCHAR(255)),
            @UserID
        );
        
        
        COMMIT TRANSACTION;
        PRINT 'Book borrowed successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END

IF OBJECT_ID('Library.ReturnBook', 'P') IS NOT NULL
    DROP PROCEDURE Library.ReturnBook;
GO

CREATE PROCEDURE [Library].[ReturnBook]
    @CopyID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Start a transaction to ensure atomicity.
    BEGIN TRANSACTION;

    BEGIN TRY
        -- --- Step 1: Declare variables and constants ---
        DECLARE @LoanID BIGINT;
        DECLARE @DueDate DATETIME;
        DECLARE @FineAmount DECIMAL(10, 2) = 0.00;
        DECLARE @FinePerDay DECIMAL(10, 2) = 0.25; -- Set a daily fine rate. This can be configured.
        
        -- --- Step 2: Find the active loan for the specified book copy ---
        -- An active loan is one that has not yet been returned (ReturnDate IS NULL).
        SELECT 
            @LoanID = LoanID,
            @DueDate = DueDate
        FROM 
            [Library].[Loans]
        WHERE 
            CopyID = @CopyID 
            AND ReturnDate IS NULL;

        -- If no active loan is found, the book cannot be returned.
        IF @LoanID IS NULL
        BEGIN
            RAISERROR('This book copy is not currently recorded as being on loan.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- --- Step 3: Calculate fines if the book is overdue ---
        -- A fine is applied if the current date is after the due date.
        IF GETDATE() > @DueDate
        BEGIN
            SET @FineAmount = CAST(DATEDIFF(day, @DueDate, GETDATE()) AS DECIMAL(10, 2)) * @FinePerDay;
        END

        -- --- Step 4: Update the loan record with the return date and any fines ---
        -- This UPDATE is the action that will fire the trigger.
        UPDATE [Library].[Loans]
        SET 
            ReturnDate = GETDATE(),
            FinesApplied = @FineAmount
        WHERE 
            LoanID = @LoanID;
		DECLARE @UserID NVARCHAR(128) = SUSER_SNAME();
        -- --- Step 5: Log the return event ---
        INSERT INTO [Library].[LibraryLog] (EventType, Description, AffectedTable, AffectedRecordID, UserID)
        VALUES (
            'Book Returned',
            'Book copy with ID ' + CAST(@CopyID AS VARCHAR(10)) + ' was returned. LoanID: ' + CAST(@LoanID AS VARCHAR(20)) + N'. Fine applied: $' + CAST(@FineAmount AS VARCHAR(20)),
            'Library.Loans',
            CAST(@LoanID AS VARCHAR(255)),
            @UserID
        );

        -- If all steps succeed, commit the transaction.
        COMMIT TRANSACTION;
        PRINT 'Book returned successfully. Fine of $' + CAST(@FineAmount AS VARCHAR(20)) + ' was applied.';

    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back all changes.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Propagate the error.
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('Library.AddBookWithCopies', 'P') IS NOT NULL
    DROP PROCEDURE Library.AddBookWithCopies;
GO

CREATE PROCEDURE [Library].[AddBookWithCopies]
    -- Parameters for the new book
    @ISBN VARCHAR(20),
    @Title NVARCHAR(255),
    @PublisherID INT,
    @PublicationYear INT = NULL,
    @Edition NVARCHAR(50) = NULL,
    @Description NTEXT = NULL,
    
    -- Parameters for the copies
    @NumberOfCopies INT,
    @AcquisitionDate DATE = NULL,
    @PurchasePrice DECIMAL(10, 2) = NULL,
    @LocationInLibrary NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- --- Step 1: Validate input ---
        -- Ensure the ISBN doesn't already exist to prevent duplicates.
        IF EXISTS (SELECT 1 FROM [Library].[Books] WHERE ISBN = @ISBN)
        BEGIN
            RAISERROR('A book with this ISBN already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Default the acquisition date to today if not provided.
        IF @AcquisitionDate IS NULL
        BEGIN
            SET @AcquisitionDate = GETDATE();
        END
        
        -- --- Step 2: Insert the main book record ---
        INSERT INTO [Library].[Books] (ISBN, Title, PublicationYear, PublisherID, Edition, Description)
        VALUES (@ISBN, @Title, @PublicationYear, @PublisherID, @Edition, @Description);

        -- Get the ID of the newly created book.
        DECLARE @NewBookID INT = SCOPE_IDENTITY();

        -- --- Step 3: Add the physical copies in a loop ---
        DECLARE @AvailableStatusID INT;
        SELECT @AvailableStatusID = CopyStatusID FROM [Library].[BookCopyStatuses] WHERE StatusName = 'Available';

        IF @AvailableStatusID IS NULL
        BEGIN
            RAISERROR('The "Available" status is not defined in BookCopyStatuses. Cannot add copies.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @Counter INT = 0;
        WHILE @Counter < @NumberOfCopies
        BEGIN
            INSERT INTO [Library].[BookCopies] (BookID, AcquisitionDate, CopyStatusID, LocationInLibrary, PurchasePrice)
            VALUES (@NewBookID, @AcquisitionDate, @AvailableStatusID, @LocationInLibrary, @PurchasePrice);
            
            SET @Counter = @Counter + 1;
        END

        -- If all operations succeed, commit the transaction.
        COMMIT TRANSACTION;
        PRINT 'Successfully added book and ' + CAST(@NumberOfCopies AS VARCHAR(5)) + ' copies.';

    END TRY
    BEGIN CATCH
        -- If any error occurs, roll back the entire transaction.
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Rethrow the error for the calling application.
        THROW;
    END CATCH
END
GO


IF OBJECT_ID('Library.GenerateAllStudentBookRecommendations', 'P') IS NOT NULL
    DROP PROCEDURE Library.GenerateAllStudentBookRecommendations;
GO

CREATE PROCEDURE Library.GenerateAllStudentBookRecommendations
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartTime DATETIME = GETDATE();
    PRINT 'Starting book recommendation generation for all students at ' + CONVERT(VARCHAR, @StartTime, 120);

    -- Step 1: Clear out old recommendations to make way for the new ones.
    DELETE FROM Library.BookRecommendations;
    PRINT 'Old recommendations cleared.';

    -- Step 2: Create a temporary table to capture the output of the existing procedure.

    CREATE TABLE #TempRecommendations (
        BookID INT,
        Title NVARCHAR(255),
        Frequency INT
    );

    -- Step 3: Loop through all active students using a cursor.
    DECLARE @CurrentStudentID INT;
    DECLARE student_cursor CURSOR FOR
        SELECT s.StudentID
        FROM Education.Students s
        JOIN Education.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
        WHERE ss.StatusName = 'Active'; -- Only generate for active students

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @CurrentStudentID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Clear the temp table 
        TRUNCATE TABLE #TempRecommendations;

        
        BEGIN TRY
            INSERT INTO #TempRecommendations (BookID, Title, Frequency)
            EXEC Library.RecommendBooksToStudent @StudentID = @CurrentStudentID;
        END TRY
        BEGIN CATCH
            -- If the procedure fails for one student, log it and continue with the next
            PRINT 'Error generating recommendations for StudentID ' + CAST(@CurrentStudentID AS VARCHAR) + ': ' + ERROR_MESSAGE();
        END CATCH

        -- Now, insert the captured recommendations from the temp table into the permanent table
        IF EXISTS (SELECT 1 FROM #TempRecommendations)
        BEGIN
            INSERT INTO Library.BookRecommendations (StudentID, BookID, RecommendationScore, GeneratedDate)
            SELECT
                @CurrentStudentID,
                BookID,
                Frequency, -- Using frequency as the score
                GETDATE()
            FROM #TempRecommendations;

            PRINT '  -> Generated ' + CAST(@@ROWCOUNT AS VARCHAR) + ' recommendations for StudentID: ' + CAST(@CurrentStudentID AS VARCHAR);
        END

        FETCH NEXT FROM student_cursor INTO @CurrentStudentID;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;

    -- Drop the temporary table
    DROP TABLE #TempRecommendations;
    
    DECLARE @EndTime DATETIME = GETDATE();
    PRINT 'Book recommendation generation process finished at ' + CONVERT(VARCHAR, @EndTime, 120);
    PRINT 'Total duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS VARCHAR) + ' seconds.';
END;
GO