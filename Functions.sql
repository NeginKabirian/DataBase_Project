IF OBJECT_ID('Education.CalculateStudentGPA', 'FN') IS NOT NULL OR 
OBJECT_ID('Education.CalculateStudentGPA', 'IF') IS NOT NULL
BEGIN
	DROP FUNCTION Education.CalculateStudentGPA;
END
GO

CREATE FUNCTION  Education.CalculateStudentGPA
(
    @StudentID INT,
    @SemesterID INT NULL 
)
RETURNS DECIMAL(4,2) 
AS
BEGIN
    DECLARE @TotalGradePoints DECIMAL(18,2) = 0;   
    DECLARE @TotalCredits DECIMAL(18,2) = 0;      
    DECLARE @CalculatedGPA DECIMAL(4,2) = 0;   

	DECLARE @PassedStatusID INT;
    DECLARE @FailedStatusID INT;

	SELECT @PassedStatusID = EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE StatusName = 'Passed';
    SELECT @FailedStatusID = EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE StatusName = 'Failed';

	IF @PassedStatusID IS NOT NULL OR @FailedStatusID IS NOT NULL
    BEGIN
		SELECT
            @TotalGradePoints = ISNULL(SUM(TRY_CAST(E.Grade AS DECIMAL(4,2)) * C.Credits), 0),
			@TotalCredits = ISNULL(SUM(C.Credits), 0)
		FROM
			Education.Enrollments E
		JOIN
			 Education.OfferedCourses OC ON E.OfferedCourseID = OC.OfferedCourseID
		JOIN
             Education.Courses C ON OC.CourseID = C.CourseID
		WHERE 
			E.StudentID = @StudentID
			AND (@SemesterID IS NULL OR OC.SemesterID = @SemesterID)
			AND E.Grade IS NOT NULL
			AND E.EnrollmentStatusID IN (SELECT EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE StatusName IN ('Passed', 'Failed'))
			AND ISNUMERIC(E.Grade) = 1
	END

	IF @TotalCredits > 0
    BEGIN
        SET @CalculatedGPA = @TotalGradePoints / @TotalCredits;
    END

	RETURN @CalculatedGPA;
END;
GO

IF OBJECT_ID('Education.GetStudentRemainingCredits', 'FN') IS NOT NULL OR OBJECT_ID('Education.GetStudentRemainingCredits', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION Education.GetStudentRemainingCredits;
    PRINT 'Dropped existing Function Education.GetStudentRemainingCredits.';
END
GO

CREATE FUNCTION Education.GetStudentRemainingCredits
(
    @StudentID INT
)
RETURNS INT 
AS
BEGIN
    DECLARE @MajorID INT;
    DECLARE @RequiredMajorCredits INT;
    DECLARE @CompletedCredits INT = 0;
    DECLARE @RemainingCredits INT = 0;

	SELECT
        @MajorID = S.MajorID,
        @RequiredMajorCredits = M.RequiredCredits
    FROM
        Education.Students S
    JOIN
        Education.Majors M ON S.MajorID = M.MajorID
    WHERE
        S.StudentID = @StudentID;

	IF @MajorID IS NULL OR @RequiredMajorCredits IS NULL
    BEGIN
        RETURN 0; 
    END

	DECLARE @PassedEnrollmentStatusID INT = (SELECT EnrollmentStatusID FROM Education.EnrollmentStatuses WHERE StatusName = 'Passed');

    IF @PassedEnrollmentStatusID IS NOT NULL
    BEGIN
        SELECT
            @CompletedCredits = ISNULL(SUM(C.Credits), 0)
        FROM
            Education.Enrollments E
        JOIN
            Education.OfferedCourses OC ON E.OfferedCourseID = OC.OfferedCourseID
        JOIN
            Education.Courses C ON OC.CourseID = C.CourseID
        JOIN
            Education.Curriculum CUR ON C.CourseID = CUR.CourseID AND CUR.MajorID = @MajorID -- Ensure the course is in student's major curriculum
        WHERE
            E.StudentID = @StudentID
            AND E.EnrollmentStatusID = @PassedEnrollmentStatusID;
    END

    -- Calculate remaining credits
    SET @RemainingCredits = @RequiredMajorCredits - @CompletedCredits;

    -- if student has taken more than required
    IF @RemainingCredits < 0
    BEGIN
        SET @RemainingCredits = 0;
    END

    RETURN @RemainingCredits;
END;
GO

IF OBJECT_ID('Education.CheckCoursePrerequisitesMet', 'FN') IS NOT NULL
OR OBJECT_ID('Education.CheckCoursePrerequisitesMet', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION Education.CheckCoursePrerequisitesMet;
    PRINT 'Dropped existing Function Education.CheckCoursePrerequisitesMet.';
END
GO

CREATE FUNCTION Education.CheckCoursePrerequisitesMet
(
    @StudentID INT,
    @CourseID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @AllPrerequisitesMet BIT = 0; -- Default to false
    DECLARE @RequiredPrereqsCount INT;
    DECLARE @MetPrereqsCount INT;
    DECLARE @PassedStatusID INT;

    -- Get the 'Passed' status ID, handle trailing/leading spaces
    SELECT @PassedStatusID = EnrollmentStatusID
    FROM Education.EnrollmentStatuses
    WHERE TRIM(StatusName) = 'Passed';

    -- If 'Passed' status isn't defined, we can't check, so it's a failure
    IF @PassedStatusID IS NULL
        RETURN 0;

    -- 1. Count how many prerequisites are required for the target course
    SELECT @RequiredPrereqsCount = COUNT(PrerequisiteCourseID)
    FROM Education.Prerequisites
    WHERE CourseID = @CourseID;

    -- 2. If there are no prerequisites, the condition is met.
    IF @RequiredPrereqsCount = 0
    BEGIN
        SET @AllPrerequisitesMet = 1;
        RETURN @AllPrerequisitesMet;
    END

    -- 3. Count how many of those required prerequisites the student has passed
    SELECT @MetPrereqsCount = COUNT(DISTINCT P.PrerequisiteCourseID)
    FROM Education.Prerequisites P
    INNER JOIN Education.Enrollments E ON 1=1 -- This will be filtered by subquery
    INNER JOIN Education.OfferedCourses OC ON E.OfferedCourseID = OC.OfferedCourseID
    WHERE
        P.CourseID = @CourseID                        -- Look at prereqs for the target course
        AND E.StudentID = @StudentID                  -- For the specific student
        AND E.EnrollmentStatusID = @PassedStatusID      -- Only consider 'Passed' courses
        AND OC.CourseID = P.PrerequisiteCourseID;     -- The passed course must be one of the prerequisites

    IF @MetPrereqsCount = @RequiredPrereqsCount
    BEGIN
        SET @AllPrerequisitesMet = 1;
    END

    RETURN @AllPrerequisitesMet;
END;
GO



IF OBJECT_ID('Education.GetStudentCurrentAcademicStatus', 'FN') IS NOT NULL
OR OBJECT_ID('Education.GetStudentCurrentAcademicStatus', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION Education.GetStudentCurrentAcademicStatus;
    PRINT 'Dropped existing Function Education.GetStudentCurrentAcademicStatus.';
END
GO

CREATE FUNCTION Education.GetStudentCurrentAcademicStatus
(
    @StudentID INT
)
RETURNS NVARCHAR(50) 
AS
BEGIN
    DECLARE @CurrentStatus NVARCHAR(50);

    SELECT TOP 1 @CurrentStatus = SAH.AcademicStatus
    FROM Education.StudentAcademicHistory SAH
    WHERE SAH.StudentID = @StudentID
    ORDER BY
        SAH.StatusDate DESC, -- Get the most recent status by date
        SAH.SemesterID DESC; -- If dates are the same, prefer the higher (more recent) semester ID

    
    IF @CurrentStatus IS NULL
    BEGIN
        SET @CurrentStatus = 'N/A - No History'; 
    END

    RETURN @CurrentStatus;
END;
GO




IF OBJECT_ID('Education.GetOfferedCourseAvailableCapacity', 'FN') IS NOT NULL
OR OBJECT_ID('Education.GetOfferedCourseAvailableCapacity', 'IF') IS NOT NULL
BEGIN
    DROP FUNCTION Education.GetOfferedCourseAvailableCapacity;
    PRINT 'Dropped existing Function Education.GetOfferedCourseAvailableCapacity.';
END
GO

CREATE FUNCTION Education.GetOfferedCourseAvailableCapacity
(
    @OfferedCourseID INT
)
RETURNS INT 
AS
BEGIN
    DECLARE @TotalCapacity INT;
    DECLARE @EnrolledCount INT;
    DECLARE @EnrolledStatusID INT;

 
    SELECT @TotalCapacity = Capacity
    FROM Education.OfferedCourses
    WHERE OfferedCourseID = @OfferedCourseID;


    IF @TotalCapacity IS NULL
    BEGIN
        RETURN -1;
    END

  
    SELECT @EnrolledStatusID = EnrollmentStatusID
    FROM Education.EnrollmentStatuses
    WHERE TRIM(StatusName) = 'Enrolled';


    IF @EnrolledStatusID IS NULL
    BEGIN
        RETURN @TotalCapacity;
    END

    
    SELECT @EnrolledCount = COUNT(EnrollmentID)
    FROM Education.Enrollments
    WHERE OfferedCourseID = @OfferedCourseID
    AND EnrollmentStatusID = @EnrolledStatusID;

    
    RETURN @TotalCapacity - @EnrolledCount;
END;
GO
-----------------------------------------------------------------------------------------------------------------
--Library Function
CREATE FUNCTION Library.CountAvailableBookCopies(@BookID INT)
RETURNS INT
AS
BEGIN
    DECLARE @AvailableCount INT;

    SELECT @AvailableCount = COUNT(*)
    FROM BookCopies
    WHERE BookID = @BookID AND CopyStatusID = (
        SELECT CopyStatusID FROM BookCopyStatuses WHERE StatusName = 'Available'
    );

    RETURN @AvailableCount;
END;
Go
--DROP FUNCTION IF EXISTS Library.HasMemberOverdueBooks;

CREATE FUNCTION Library.HasMemberOverdueBooks(@MemberID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @HasOverdue BIT;

    IF EXISTS (
        SELECT 1
        FROM Library.Loans L
        JOIN Library.LibraryMembers M ON L.MemberID = M.MemberID
        JOIN Library.MemberAccountStatuses S ON M.AccountStatusID = S.AccountStatusID
        WHERE L.MemberID = @MemberID
          AND L.ReturnDate IS NULL
          AND L.DueDate < GETDATE()
          AND S.StatusName = 'Active'
    )
        SET @HasOverdue = 1;
    ELSE
        SET @HasOverdue = 0;

    RETURN @HasOverdue;
END;
GO

Go
CREATE FUNCTION Library.GetMemberActiveLoanCount(@MemberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @ActiveLoanCount INT;

    SELECT @ActiveLoanCount = COUNT(*)
    FROM Library.Loans L
    JOIN Library.LibraryMembers M ON L.MemberID = M.MemberID
    JOIN Library.MemberAccountStatuses S ON M.AccountStatusID = S.AccountStatusID
    WHERE L.MemberID = @MemberID
      AND L.ReturnDate IS NULL
      AND S.StatusName = 'Active';
    RETURN @ActiveLoanCount;
END;
Go
CREATE FUNCTION Library.CalculateFineForLoan(@LoanID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Fine DECIMAL(10,2) = 0;
    DECLARE @ReturnDate DATE;
    DECLARE @DueDate DATE;
    DECLARE @DailyFineRate DECIMAL(10,2) = 2000; 
    DECLARE @BookPrice DECIMAL(10,2);
    DECLARE @MemberStatus NVARCHAR(50);

    SELECT 
        @ReturnDate = L.ReturnDate,
        @DueDate = L.DueDate,
        @BookPrice = BC.PurchasePrice,
        @MemberStatus = S.StatusName
    FROM Library.Loans L
    JOIN Library.LibraryMembers M ON L.MemberID = M.MemberID
    JOIN Library.MemberAccountStatuses S ON M.AccountStatusID = S.AccountStatusID
    JOIN Library.BookCopies BC ON L.CopyID = BC.CopyID
    WHERE L.LoanID = @LoanID;

    IF @ReturnDate IS NOT NULL 
       AND @ReturnDate > @DueDate
       AND @MemberStatus = 'Active'
    BEGIN
        SET @Fine = DATEDIFF(DAY, @DueDate, @ReturnDate) * @DailyFineRate;

        IF @Fine > @BookPrice
            SET @Fine = @BookPrice;
    END
    RETURN @Fine;
END;
GO
CREATE FUNCTION Library.IsBookCopyAvailable(@CopyID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 0;
    DECLARE @StatusName NVARCHAR(50);

    SELECT @StatusName = S.StatusName
    FROM Library.BookCopies C
    JOIN Library.BookCopyStatuses S ON C.CopyStatusID = S.CopyStatusID
    WHERE C.CopyID = @CopyID;

    IF @StatusName = 'Available' AND NOT EXISTS (
        SELECT 1
        FROM Library.Loans
        WHERE CopyID = @CopyID AND ReturnDate IS NULL
    )
    BEGIN
        SET @IsAvailable = 1;
    END

    RETURN @IsAvailable;
END;
GO


