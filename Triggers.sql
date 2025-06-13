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