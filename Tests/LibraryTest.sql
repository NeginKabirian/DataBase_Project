
-- # 1. Testing Library.CountAvailableBookCopies Function
--Tables
select *
from Library.Books
select *
from Library.BookCopies

DECLARE @isbn1 NVARCHAR(20) = '978-0132350884'; --Clean Code: A Handbook of Agile Software Craftsmanship
DECLARE @isbn2 NVARCHAR(20) = '978-0321125217'; --Refactoring: Improving the Design of Existing Code


DECLARE @bookId1 INT = (SELECT BookID FROM Library.Books WHERE ISBN = @isbn1);
DECLARE @bookId2 INT = (SELECT BookID FROM Library.Books WHERE ISBN = @isbn2);

-- Execute 
PRINT 'Counting available copies for ISBN: ' + @isbn1;
SELECT Library.CountAvailableBookCopies(@bookId1) AS AvailableCopies;

PRINT 'Counting available copies for ISBN: ' + @isbn2;
SELECT Library.CountAvailableBookCopies(@bookId2) AS AvailableCopies;
GO



-- Testing Borrow & Return Procedures and Related Triggers/Functions

-- 2. BORROWING PROCESS --  
--Execute before and after borrow

DECLARE @studentNationalIDForBorrow NVARCHAR(100) = '1234567890'; -- Hossein
DECLARE @isbnToBorrow NVARCHAR(20) = '978-0132350884';       -- Clean Code


DECLARE @memberId INT;
DECLARE @bookIdToBorrow INT;
DECLARE @copyIdToBorrow1 INT;
DECLARE @copyIdToBorrow2 INT;

SELECT @memberId = mem.MemberID
FROM Library.LibraryMembers AS mem
JOIN Education.Students AS stu ON mem.StudentID = stu.StudentID
WHERE stu.NationalID = @studentNationalIDForBorrow;
SELECT @bookIdToBorrow = BookID FROM Library.Books WHERE ISBN = @isbnToBorrow; --Clean Code


SELECT TOP 1 @copyIdToBorrow1 = CopyID FROM Library.BookCopies WHERE BookID = @bookIdToBorrow AND CopyStatusID = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Available');
SELECT TOP 1 @copyIdToBorrow2 = CopyID FROM Library.BookCopies WHERE BookID = @bookIdToBorrow AND CopyStatusID = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Available') AND CopyID <> @copyIdToBorrow1;


--Table 
select *
from Education.Students
select *
from Library.LibraryMembers
select *
from Library.Loans
select *
from Library.Books
select* 
from Library.BookCopies
select *
from Library.BookCopyStatuses
select * 
from Library.LibraryLog
ORDER BY LogTimestamp ASC


--IsBookCopyAvailable Function
SELECT Library.IsBookCopyAvailable(@copyIdToBorrow1) As IsBookCopyAvailable; --Clean Code
--Library.GetMemberActiveLoanCount Function
Select Library.GetMemberActiveLoanCount(@memberId) As LoanCount; --Hossein 
-- Library.HasMemberOverdueBooks Function
SELECT Library.HasMemberOverdueBooks(@memberId) AS HasOverdue;


--Borrow Book
EXEC Library.BorrowBook @MemberID = @memberId, @CopyID = @copyIdToBorrow1; --Hossein  --Clean Code **
EXEC Library.BorrowBook @MemberID = @memberId, @CopyID = @copyIdToBorrow2;--Hossein  --Clean Code **
-- Updates the book copy status to "Borrowed" after a new loan is inserted.



-- ---3. RETURNING PROCESS ---


DECLARE @studentNationalID NVARCHAR(10) = '1234567890';    --Hossein
DECLARE @isbnToTest NVARCHAR(20) = '978-0132350884'; -- Clean Code


DECLARE @memberId INT;
DECLARE @bookId INT;
DECLARE @copyId INT;

SELECT @memberId = mem.MemberID
FROM Library.LibraryMembers AS mem
JOIN Education.Students AS stu ON mem.StudentID = stu.StudentID
WHERE stu.NationalID = @studentNationalID;

-- Find BookID using ISBN
SELECT @bookId = BookID FROM Library.Books WHERE ISBN = @isbnToTest;

-- Find ONE available copy of this book
SELECT TOP 1 @copyId = CopyID 
FROM Library.BookCopies 
WHERE BookID = @bookId AND CopyStatusID = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Borrowed');

 --> Finding the loan record for CopyID: ' + CAST(@copyId AS VARCHAR);

SELECT LoanID, MemberID, CopyID, LoanDate, DueDate, ReturnDate 
FROM Library.Loans 
WHERE CopyID = @copyId AND ReturnDate IS NULL;

--> Updating DueDate to 15 days in the past to force a fine...';

-- This UPDATE statement makes the book overdue
UPDATE Library.Loans
SET DueDate = DATEADD(day, -15, GETDATE())
WHERE CopyID = @copyId AND ReturnDate IS NULL;

SELECT LoanID, MemberID, CopyID, LoanDate, DueDate, ReturnDate 
FROM Library.Loans 
WHERE CopyID = @copyId AND ReturnDate IS NULL;

SELECT Library.HasMemberOverdueBooks(@memberId) AS HasOverdue;


--Table 
select *
from Education.Students
select *
from Library.LibraryMembers
select *
from Library.Loans
select *
from Library.Books
select* 
from Library.BookCopies
select *
from Library.BookCopyStatuses
select * 
from Library.LibraryLog
ORDER BY LogTimestamp ASC
--Return Book
EXEC Library.ReturnBook @CopyID = @copyId; --**





-- # 4. Testing Library.AddBookWithCopies & TR_Books_LogChanges Trigger

DECLARE @publisherName NVARCHAR(100) = 'O''Reilly Media'; 
DECLARE @publisherId INT = (SELECT PublisherID FROM Library.Publishers WHERE PublisherName = @publisherName);

EXEC Library.AddBookWithCopies
    @ISBN = '978-1492057634', 
    @Title = 'CLRS',
    @PublisherID = @publisherId,
    @PublicationYear = 2022,
    @Edition = '1st',
    @Description = 'A comprehensive look at the data Structure landscape.',
    @NumberOfCopies = 2,
    @AcquisitionDate = '2024-01-15',
    @PurchasePrice = 55.00,
    @LocationInLibrary = 'Section D - Shelf 1';

SELECT * FROM Library.Books;
SELECT * FROM Library.BookCopies;
SELECT * From Library.LibraryLog
ORDER BY LogTimestamp ASC;




--# 5. Testing Student Registration & TR_LibraryMembers_LogChanges Trigger
Declare @MajorID INT;
SELECT @MajorID = MajorID FROM Education.Majors WHERE MajorName = 'Computer Engineering';
EXEC Education.RegisterStudent @NationalID = '1434567890', @FirstName = 'Negin', @LastName = 'Kabirian', @MajorID = @MajorID, @DateOfBirth = '2005-01-23',
    @Email = 'negink1383@gmail.com',@PhoneNumber = '09121112235',@RegisteredByUserID = 'TestScript';
Declare @StudentId Int;
DECLARE @studentNationalID NVARCHAR(10) = '1434567890'; --Negin
select  @StudentId = StudentID  from Education.Students where @studentNationalID = NationalID;

DECLARE @SuspendedStatusID INT = (SELECT AccountStatusID FROM Library.MemberAccountStatuses WHERE StatusName = 'Suspended');
UPDATE Library.LibraryMembers
SET AccountStatusID = @SuspendedStatusID
WHERE StudentID = @StudentId;

SELECT * FROM Library.LibraryLog
WHERE AffectedTable = 'Library.LibraryMembers'
ORDER BY LogTimestamp ASC;


--6 Recommend Book

    DECLARE @targetStudent_NationalID NVARCHAR(10) = '1234567890'; -- Hossein Abbasi
    DECLARE @similarStudent_NationalID NVARCHAR(10) = '1234567891'; -- Sara Mohammadi

    DECLARE @commonBook1_ISBN NVARCHAR(20) = '978-0321125217'; -- Refactoring 
    DECLARE @commonBook2_ISBN NVARCHAR(20) = '978-0132350884'; -- Clean Code 
    DECLARE @recommendBook_ISBN NVARCHAR(20) = '978-0321765723'; -- The Lord of the Rings 

   
    DECLARE @targetStudentID INT, @targetMemberID INT;
    SELECT @targetStudentID = s.StudentID, @targetMemberID = m.MemberID 
    FROM Education.Students s JOIN Library.LibraryMembers m ON s.StudentID = m.StudentID WHERE s.NationalID = @targetStudent_NationalID;

    DECLARE @similarStudentID INT, @similarMemberID INT;
    SELECT @similarStudentID = s.StudentID, @similarMemberID = m.MemberID 
    FROM Education.Students s JOIN Library.LibraryMembers m ON s.StudentID = m.StudentID WHERE s.NationalID = @similarStudent_NationalID;

    EXEC Education.UpdateStudentStatus
        @StudentID = @similarStudentID,
        @NewStatusName = 'Active';

    DECLARE @commonBook1_ID INT = (SELECT BookID FROM Library.Books WHERE ISBN = @commonBook1_ISBN);
    DECLARE @commonBook2_ID INT = (SELECT BookID FROM Library.Books WHERE ISBN = @commonBook2_ISBN);
    DECLARE @recommendBook_ID INT = (SELECT BookID FROM Library.Books WHERE ISBN = @recommendBook_ISBN);


    DECLARE @availableStatusID INT = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Available');
    
    DECLARE @copy_common1_target INT = (SELECT TOP 1 CopyID FROM Library.BookCopies WHERE BookID = @commonBook1_ID AND CopyStatusID = @availableStatusID);
    DECLARE @copy_common1_similar INT = (SELECT TOP 1 CopyID FROM Library.BookCopies WHERE BookID = @commonBook1_ID AND CopyStatusID = @availableStatusID AND CopyID <> @copy_common1_target);

    DECLARE @copy_common2_target INT = (SELECT TOP 1 CopyID FROM Library.BookCopies WHERE BookID = @commonBook2_ID AND CopyStatusID = @availableStatusID);
    DECLARE @copy_common2_similar INT = (SELECT TOP 1 CopyID FROM Library.BookCopies WHERE BookID = @commonBook2_ID AND CopyStatusID = @availableStatusID AND CopyID <> @copy_common2_target);
    
    DECLARE @copy_recommend_similar INT = (SELECT TOP 1 CopyID FROM Library.BookCopies WHERE BookID = @recommendBook_ID AND CopyStatusID = @availableStatusID);


    -- Hossein (Target Student) borrows two common books
    EXEC Library.BorrowBook @MemberID = @targetMemberID, @CopyID = @copy_common1_target;
    EXEC Library.BorrowBook @MemberID = @targetMemberID, @CopyID = @copy_common2_target;
    -- Sara (Similar Student) borrows the same two books PLUS the recommendation book
    PRINT '-> Sara (MemberID ' + CAST(@similarMemberID AS VARCHAR) + ') is borrowing "Refactoring" (CopyID ' + CAST(@copy_common1_similar AS VARCHAR) + ')';
    EXEC Library.BorrowBook @MemberID = @similarMemberID, @CopyID = @copy_common1_similar;
    
    PRINT '-> Sara (MemberID ' + CAST(@similarMemberID AS VARCHAR) + ') is borrowing "Clean Code" (CopyID ' + CAST(@copy_common2_similar AS VARCHAR) + ')';
    EXEC Library.BorrowBook @MemberID = @similarMemberID, @CopyID = @copy_common2_similar;

    PRINT '-> Sara (MemberID ' + CAST(@similarMemberID AS VARCHAR) + ') is borrowing "The Lord of the Rings" (CopyID ' + CAST(@copy_recommend_similar AS VARCHAR) + ')';
    EXEC Library.BorrowBook @MemberID = @similarMemberID, @CopyID = @copy_recommend_similar;

 
    -- Execute the actual procedure to be tested
    EXEC Library.RecommendBooksToStudent @StudentID = @targetStudentID;


