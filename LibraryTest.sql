--Library.CountAvailableBookCopies
--Tables
select *
from Library.BookCopies
--Excecute
SELECT Library.CountAvailableBookCopies(11) AS AvailableCopies;
SELECT Library.CountAvailableBookCopies(13) AS AvailableCopies;

-----------------------------------------------
--Library PROCEDURE , Trigger And Function
-----------------------------------------------
--Borrow Book PROCEDURE
--Tables Before
select *
from Library.LibraryMembers

select *
from Library.Loans

select* 
from Library.BookCopies
select *
from Library.BookCopyStatuses

select * 
from Library.LibraryLog
--Excecute
SELECT Library.IsBookCopyAvailable(47) As IsBookCopyAvailable; --IsBookCopyAvailable Function
EXEC Library.BorrowBook @MemberID = 4, @CopyID = 45;
SELECT Library.IsBookCopyAvailable(45) As IsBookCopyAvailable; --IsBookCopyAvailable Function
EXEC Library.BorrowBook @MemberID = 5, @CopyID = 45;  --Cant Borrow
EXEC Library.BorrowBook @MemberID = 4, @CopyID = 48;
--Table After
select *
from Library.Loans
--Triger Test
-- Updates the book copy status to "Borrowed" after a new loan is inserted.
select* 
from Library.BookCopies

select * 
from Library.LibraryLog
--Library.HasMemberOverdueBooks
--Excecute
SELECT Library.HasMemberOverdueBooks(4) AS HasOverdue;
SELECT 
    MemberID,
    Library.HasMemberOverdueBooks(MemberID) AS HasOverdue
FROM 
    Library.LibraryMembers;
Select Library.GetMemberActiveLoanCount(4) As LoanCount;
Select Library.GetMemberActiveLoanCount(5) As LoanCount;


--Library.ReturnBook Procedure
--Excecute
EXEC Library.ReturnBook @CopyID = 45;
EXEC Library.ReturnBook @CopyID = 48;

-- Updates the book copy status to "Available" when a book is returned.
--Triger Test
--Library.TR_Loans_AfterUpdate_HandleReturnAndUpdateBookCopyStatus
SELECT Library.IsBookCopyAvailable(45) As IsBookCopyAvailable;  --
SELECT Library.IsBookCopyAvailable(48) As IsBookCopyAvailable; --
--Table After
select *
from Library.Loans
select* 
from Library.BookCopies
select *
from Library.BookCopyStatuses

select * 
from Library.LibraryLog

--Library.AddBookWithCopies Procedure
--Exec
select *
from Library.Publishers
EXEC Library.AddBookWithCopies
    @ISBN = '9780136042594',
    @Title = 'Artificial Intelligence: A Modern Approach',
    @PublisherID = 12,  
    @PublicationYear = 2020,
    @Edition = '4th',
    @Description = 'Reference book on AI by Russell and Norvig.',
    @NumberOfCopies = 3,
    @AcquisitionDate = '2025-06-25',
    @PurchasePrice = 120.00,
    @LocationInLibrary = 'Section A - Shelf 3';
--Table After
SELECT * FROM Library.Books;

SELECT * FROM Library.BookCopies;
--Test TRIGGER Library.TR_Books_LogChanges
SELECT * FROM Library.LibraryLog; 
-- Test TRIGGER Library.TR_LibraryMembers_LogChanges
select * from Library.LibraryMembers;
select * from Library.MemberAccountStatuses;
select * from Education.Students;
SELECT * FROM Library.Books;
SELECT * FROM Library.BookCopies;
--Exec Insert
Declare @MajorID INT;
SELECT @MajorID = MajorID FROM Education.Majors WHERE MajorName = 'Computer Engineering';
EXEC Education.RegisterStudent @NationalID = '1434567890', @FirstName = 'Negin', @LastName = 'Kabirian', @MajorID = @MajorID, @DateOfBirth = '2005-01-23',
    @Email = 'negink1383@gmail.com',@PhoneNumber = '09121112235',@RegisteredByUserID = 'TestScript';

--Exec Update
UPDATE Library.LibraryMembers
SET AccountStatusID = 15  --Suspended
WHERE StudentID = 10;
--Table After
SELECT * FROM Library.LibraryLog
WHERE AffectedTable = 'Library.LibraryMembers'
ORDER BY LogID DESC;

--

-- ====================================================================
-- FINAL COMPATIBLE TEST SCRIPT for Library.RecommendBooksToStudent
-- This version uses a simplified, more compatible error handler.
-- ====================================================================
UPDATE Library.LibraryMembers
SET AccountStatusID = 13  --Suspended
WHERE StudentID = 10;
SET NOCOUNT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY
    PRINT '--- STEP 1: Setting up corrected loan history for the test scenario ---';

    -- Student and Member IDs from your data
    DECLARE @TargetStudentID INT = 10; -- Negin Kabirian
    DECLARE @TargetMemberID INT = 14;

    DECLARE @SimilarStudentID INT = 9; -- Sara Mohammadi
    DECLARE @SimilarMemberID INT = 8;

    -- Book and Copy IDs
    DECLARE @BookID_CleanCode INT = 22;
    DECLARE @BookID_AI INT = 24;
    DECLARE @CopyID_AI INT = 58;

    -- === FIX FOR IDENTITY_INSERT ERROR ===
    PRINT '-> Enabling IDENTITY_INSERT for Library.BookCopies to insert a test record.';
    SET IDENTITY_INSERT Library.BookCopies ON;

    -- Insert a temporary copy of "Clean Code" for the test
    DECLARE @NewCopyID_CleanCode_ForSara INT = 101; 
    
    IF NOT EXISTS (SELECT 1 FROM Library.BookCopies WHERE CopyID = @NewCopyID_CleanCode_ForSara)
    BEGIN
        PRINT '-> Inserting a temporary copy of "Clean Code" (BookID=22) with explicit CopyID=101.';
        INSERT INTO Library.BookCopies (CopyID, BookID, AcquisitionDate, CopyStatusID, LocationInLibrary, PurchasePrice)
        VALUES (@NewCopyID_CleanCode_ForSara, @BookID_CleanCode, GETDATE(), 15, 'Test Shelf', 0.00);
    END
    
    SET IDENTITY_INSERT Library.BookCopies OFF;
    PRINT '-> IDENTITY_INSERT for Library.BookCopies is now OFF.';
    -- ==========================================

    -- Create loan history for Negin (Target User)
    PRINT '-> Negin borrows "The Lord of the Rings" (CopyID=51)';
    EXEC Library.BorrowBook @MemberID = @TargetMemberID, @CopyID = 51;

    PRINT '-> Negin borrows "Clean Code" (CopyID=56)';
    EXEC Library.BorrowBook @MemberID = @TargetMemberID, @CopyID = 56;

    -- Create loan history for Sara (Similar User)
    PRINT '-> Sara borrows "The Lord of the Rings" (CopyID=52)';
    EXEC Library.BorrowBook @MemberID = @SimilarMemberID, @CopyID = 52; 

    PRINT '-> Sara borrows "Clean Code" (using the temporary CopyID=101)';
    EXEC Library.BorrowBook @MemberID = @SimilarMemberID, @CopyID = @NewCopyID_CleanCode_ForSara;

    PRINT '-> Sara borrows "Artificial Intelligence" (The book to be recommended)';
    EXEC Library.BorrowBook @MemberID = @SimilarMemberID, @CopyID = @CopyID_AI;

    PRINT '--- Loan history created successfully. ---';
    PRINT '';
    PRINT '--- STEP 2: Executing recommendation procedure for Negin (StudentID=10) ---';
    PRINT '--- Expected Result: Recommendation for "Artificial Intelligence..." (BookID=24) ---';
    PRINT '------------------------------------------------------------------------------------';

    EXEC Library.RecommendBooksToStudent @StudentID = @TargetStudentID;
    
    PRINT '------------------------------------------------------------------------------------';
    PRINT '';
    PRINT '--- Test completed. Rolling back all changes. ---';

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH
    -- Simplified and more compatible error handler
    -- Attempt to turn off IDENTITY_INSERT just in case the error happened after it was turned on.
    -- This is safe to run even if it's already off.
    SET IDENTITY_INSERT Library.BookCopies OFF;
    
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT '!!! An error occurred. All changes have been rolled back. !!!';
    -- Displaying the error message that occurred inside the TRY block
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO