IF OBJECT_ID('Education.CalculateStudentGPA', 'FN') IS NOT NULL OR 
OBJECT_ID('Education.CalculateStudentGPA', 'IF') IS NOT NULL
BEGIN
	DROP FUNCTION Education.CalculateStudentGPA;
END
GO

CREATE FUNCTION  Education.CalculateStudentGPA
(
    @StudentID INT,
    @SemesterID INT NULL --اگر مقدارش هیچ باشد، معدل کل حساب میشود
)
RETURNS DECIMAL(4,2) -- معدل معمولاً با دو رقم اعشار نمایش داده می‌شود.
AS
BEGIN
    DECLARE @TotalGradePoints DECIMAL(18,2) = 0; --مجموع نمره ضربدر واحد
    DECLARE @TotalCredits DECIMAL(18,2) = 0;    -- مجموع واحدها
    DECLARE @CalculatedGPA DECIMAL(4,2) = 0; --نتیجه نهایی معدل

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

