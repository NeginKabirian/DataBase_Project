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

