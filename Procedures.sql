
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
