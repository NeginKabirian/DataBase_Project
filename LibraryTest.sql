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

EXEC Library.BorrowBook @MemberID = 4, @CopyID = 45;
EXEC Library.BorrowBook @MemberID = 5, @CopyID = 45;
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
