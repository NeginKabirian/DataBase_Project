IF OBJECT_ID('Education.TR_Students_ValidateAndInsert', 'TR') IS NOT NULL
    DROP TRIGGER Education.TR_Students_ValidateAndInsert;
GO

CREATE TRIGGER Education.TR_Students_ValidateAndInsert
ON Education.Students
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @NationalID VARCHAR(20), @FirstName NVARCHAR(100), @LastName NVARCHAR(100), @DateOfBirth DATE, @EnrollmentDate DATE, @MajorID INT, 
			@StudentStatusID INT, @Email VARCHAR(255), @PhoneNumber VARCHAR(20);

	SELECT @NationalID = i.NationalID, @FirstName = i.FirstName, @LastName = i.LastName, @DateOfBirth = i.DateOfBirth,
	    @EnrollmentDate = ISNULL(i.EnrollmentDate, GETDATE()),@MajorID = i.MajorID, @StudentStatusID = i.StudentStatusID, 
		@Email = i.Email, @PhoneNumber = i.PhoneNumber
    FROM inserted i;

	DECLARE @IsValidNationalID BIT = 1;
	IF LEN(ISNULL(TRIM(@NationalID), '')) <> 10 OR ISNUMERIC(TRIM(@NationalID)) = 0
    BEGIN
        SET @IsValidNationalID = 0;
    END

	IF @IsValidNationalID = 0
    BEGIN
        RAISERROR('Invalid National ID format: "%s". Registration stopped.', 16, 1, @NationalID);
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM Education.Students WHERE NationalID = @NationalID)
    BEGIN
        RAISERROR('A student with National ID "%s" already exists.', 16, 1, @NationalID);
        RETURN;
    END

	INSERT INTO Education.Students (NationalID, FirstName, LastName, DateOfBirth, EnrollmentDate, MajorID, StudentStatusID, Email, PhoneNumber)
    VALUES (@NationalID, @FirstName, @LastName, @DateOfBirth, @EnrollmentDate, @MajorID, @StudentStatusID, @Email, @PhoneNumber);
END;
GO



IF OBJECT_ID('Education.TR_Students_AfterInsert_CreateLibraryAccount', 'TR') IS NOT NULL
    DROP TRIGGER Education.TR_Students_AfterInsert_CreateLibraryAccount;
GO

CREATE TRIGGER Education.TR_Students_AfterInsert_CreateLibraryAccount
ON Education.Students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- If the trigger was fired but no rows were affected, do nothing.
    IF NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        RETURN;
    END

    -- Using a cursor to handle multi-row inserts robustly
    DECLARE @StudentID INT, @FirstName NVARCHAR(100), @LastName NVARCHAR(100);
    DECLARE student_cursor CURSOR FOR
        SELECT StudentID, FirstName, LastName FROM inserted;

    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentID, @FirstName, @LastName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            -- Execute the procedure to create the library member
            EXEC Library.CreateLibraryMemberFromStudent
                @StudentID = @StudentID,
                @FirstName = @FirstName,
                @LastName = @LastName;
        END TRY
        BEGIN CATCH
            -- Check if the transaction is uncommittable
            IF (XACT_STATE()) = -1
            BEGIN
                PRINT 'An uncommittable transaction was found. Rolling back transaction.';
                ROLLBACK TRANSACTION;
                DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
                RAISERROR('Error creating library account for StudentID %d. The student registration has been rolled back. Original Error: %s', 16, 1, @StudentID, @ErrorMessage);
                
                BREAK; 
            END
            ELSE
            BEGIN
                DECLARE @ErrorMsgLog NVARCHAR(4000) = ERROR_MESSAGE();
                INSERT INTO Education.EducationLog (EventType, Description, AffectedTable, AffectedRecordID, UserID)
                VALUES ('LibraryAccountCreationFailedViaTrigger', 
                        'Error creating library account for new student ID: ' + CAST(@StudentID AS VARCHAR) + '. Error: ' + @ErrorMsgLog, 
                        'Education.Students', 
                        CAST(@StudentID AS VARCHAR), 
                        SUSER_SNAME());
            END;
        END CATCH

        FETCH NEXT FROM student_cursor INTO @StudentID, @FirstName, @LastName;
    END

    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;
--Library
GO
IF OBJECT_ID('Education.Trg_UpdateLibraryAccountAndLog', 'TR') IS NOT NULL
    DROP TRIGGER Education.Trg_UpdateLibraryAccountAndLog;
GO

CREATE TRIGGER Education.Trg_UpdateLibraryAccountAndLog
ON Education.Students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InactiveStatusID INT = (
        SELECT AccountStatusID FROM Library.MemberAccountStatuses WHERE StatusName = 'Inactive'
    );
    DECLARE @ActiveStatusID INT = (
        SELECT AccountStatusID FROM Library.MemberAccountStatuses WHERE StatusName = 'Active'
    );
    UPDATE LM
    SET LM.AccountStatusID = @InactiveStatusID
    FROM Library.LibraryMembers AS LM
    INNER JOIN inserted AS i ON LM.StudentID = i.StudentID
    INNER JOIN deleted AS d ON i.StudentID = d.StudentID
    INNER JOIN Education.StudentStatuses ss ON i.StudentStatusID = ss.StudentStatusID
    WHERE ss.StatusName IN ('Graduated', 'Withdrawn', 'Expelled')
      AND i.StudentStatusID <> d.StudentStatusID;

    UPDATE LM
    SET LM.AccountStatusID = @ActiveStatusID
    FROM Library.LibraryMembers AS LM
    INNER JOIN inserted AS i ON LM.StudentID = i.StudentID
    INNER JOIN deleted AS d ON i.StudentID = d.StudentID
    INNER JOIN Education.StudentStatuses ss ON i.StudentStatusID = ss.StudentStatusID
    WHERE ss.StatusName = 'Active'
      AND i.StudentStatusID <> d.StudentStatusID;

    INSERT INTO Library.LibraryLog (
        EventType,
        Description,
        AffectedTable,
        AffectedRecordID,
        UserID
    )
    SELECT
        'UPDATE',
        'Student status changed from "' + dss.StatusName + '" to "' + iss.StatusName + '"',
        'Education.Students',
        CAST(i.StudentID AS varchar),
        SUSER_SNAME()
    FROM inserted i
    JOIN deleted d ON i.StudentID = d.StudentID
    JOIN Education.StudentStatuses dss ON d.StudentStatusID = dss.StudentStatusID
    JOIN Education.StudentStatuses iss ON i.StudentStatusID = iss.StudentStatusID
    WHERE i.StudentStatusID <> d.StudentStatusID;
END

-- Updates the book copy status to "Borrowed" after a new loan is inserted.
IF OBJECT_ID('Library.TR_Loans_AfterInsert_UpdateBookCopyStatusToBorrowed', 'TR') IS NOT NULL
    DROP TRIGGER Library.TR_Loans_AfterInsert_UpdateBookCopyStatusToBorrowed;
GO

CREATE TRIGGER [Library].[TR_Loans_AfterInsert_UpdateBookCopyStatusToBorrowed]
ON [Library].[Loans]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @BorrowedStatusID INT;
    SELECT @BorrowedStatusID = CopyStatusID 
    FROM Library.BookCopyStatuses 
    WHERE StatusName = 'Borrowed';
    IF @BorrowedStatusID IS NOT NULL
    BEGIN
        UPDATE bc
        SET bc.CopyStatusID = @BorrowedStatusID
        FROM [Library].[BookCopies] AS bc
        INNER JOIN inserted AS i ON bc.CopyID = i.CopyID;
    END
END
GO