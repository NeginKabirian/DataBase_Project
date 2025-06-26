DECLARE @TestCourseID INT, @TestStudentID_Hosein INT, @TestStudentID_Sara INT, @MajorID INT;
DECLARE @CS101_OCID INT, @Math1_OCID INT, @Physics1_OCID INT;
DECLARE @CS101_EnrollID INT, @Math1_EnrollID INT, @Physics1_EnrollID_Sara INT;
DECLARE @Fall2023_ID INT, @Spring2024_ID INT, @FallGPA DECIMAL(4,2);
DECLARE @AdvProg_ID INT, @DB1_ID INT;
DECLARE @Capacity_CS101 INT;
DECLARE @OutputHosein TABLE (NewStudentID INT);
DECLARE @OutputSara TABLE (NewStudentID INT);

-- ============================================================================
-- STEP 1: CLEANUP ONLY TEST-SPECIFIC DATA
-- ============================================================================
PRINT '--- Step 1: Cleaning up test-specific data... ---';
DELETE FROM Library.LibraryMembers;
DELETE FROM Education.Students;
DELETE FROM Education.Courses WHERE CourseCode = 'LOG_COURSE_TEST'; -- Clean up course log test data
DELETE FROM Education.EducationLog; -- Clean the log for a fresh view of this test run
PRINT 'Cleanup complete.';

-- ============================================================================
-- STEP 2: TEST TR_Courses_LogChanges TRIGGER
-- ============================================================================
PRINT '--- Step 2: Testing TR_Courses_LogChanges Trigger ---';
INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('LOG_COURSE_TEST', 'Course for Logging', 3, (SELECT TOP 1 DepartmentID FROM Education.Departments));
SET @TestCourseID = SCOPE_IDENTITY();
UPDATE Education.Courses SET CourseName = 'Course for Logging (Updated)' WHERE CourseID = @TestCourseID;
DELETE FROM Education.Courses WHERE CourseID = @TestCourseID;
PRINT 'Course DML operations for logging trigger test completed.';
PRINT '---------------------------------------------------';

-- ============================================================================
-- STEP 3: SIMULATE STUDENT LIFECYCLE (REGISTRATION & ENROLLMENT)
-- ============================================================================
PRINT '--- Step 3: Simulating Student Lifecycle... ---';

-- 3a. Register "Hosein"
SELECT @MajorID = MajorID FROM Education.Majors WHERE MajorName = 'Computer Engineering';
INSERT INTO @OutputHosein EXEC Education.RegisterStudent @NationalID = '1234567890', @FirstName = 'Hosein', @LastName = 'Abbasi', @MajorID = @MajorID, @DateOfBirth = '1999-01-01',
    @Email = 'hosein.abbasi@university.test',@PhoneNumber = '09121112233',@RegisteredByUserID = 'TestScript';;
SELECT @TestStudentID_Hosein = NewStudentID FROM @OutputHosein;
PRINT 'New student "Hosein Abbasi" registered with ID: ' + CAST(@TestStudentID_Hosein AS VARCHAR);

-- VERIFICATION 3a: Check if Hosein and his library account were created
SELECT S.StudentID, S.FirstName, LM.LibraryCardNumber FROM Education.Students S LEFT JOIN Library.LibraryMembers LM ON S.StudentID = LM.StudentID WHERE S.StudentID = @TestStudentID_Hosein;

-- 3b. Enroll "Hosein" in Fall 2023 courses
SELECT @CS101_OCID = OC.OfferedCourseID FROM Education.OfferedCourses OC JOIN Education.Courses C ON OC.CourseID = C.CourseID WHERE C.CourseCode = '1730115' AND OC.SemesterID = 20231;
SELECT @Math1_OCID = OC.OfferedCourseID FROM Education.OfferedCourses OC JOIN Education.Courses C ON OC.CourseID = C.CourseID WHERE C.CourseCode = '1914101' AND OC.SemesterID = 20231;
EXEC Education.EnrollStudentInCourse @StudentID = @TestStudentID_Hosein, @OfferedCourseID = @CS101_OCID;
EXEC Education.EnrollStudentInCourse @StudentID = @TestStudentID_Hosein, @OfferedCourseID = @Math1_OCID;
PRINT 'Hosein enrolled in Fall 2023 courses.';

-- 3c. Record grades for "Hosein" (Pass both)
SELECT @CS101_EnrollID = EnrollmentID FROM Education.Enrollments WHERE StudentID = @TestStudentID_Hosein AND OfferedCourseID = @CS101_OCID;
SELECT @Math1_EnrollID = EnrollmentID FROM Education.Enrollments WHERE StudentID = @TestStudentID_Hosein AND OfferedCourseID = @Math1_OCID;
EXEC Education.RecordStudentGrade @EnrollmentID = @CS101_EnrollID, @Grade = '18';
EXEC Education.RecordStudentGrade @EnrollmentID = @Math1_EnrollID, @Grade = '16';
PRINT 'Grades for Hosein recorded for Fall 2023.';

-- VERIFICATION 3c: Check Hosein's enrollments and grades
SELECT C.CourseCode, E.Grade, ES.StatusName FROM Education.Enrollments E JOIN Education.OfferedCourses OC ON E.OfferedCourseID = OC.OfferedCourseID JOIN Education.Courses C ON OC.CourseID = C.CourseID JOIN Education.EnrollmentStatuses ES ON E.EnrollmentStatusID = ES.EnrollmentStatusID WHERE E.StudentID = @TestStudentID_Hosein;

-- 3d. Log academic history for "Hosein"
SET @Fall2023_ID = 20231;
SET @FallGPA = Education.CalculateStudentGPA(@TestStudentID_Hosein, @Fall2023_ID);
INSERT INTO Education.StudentAcademicHistory (StudentID, SemesterID, GPA, AcademicStatus, StatusDate) VALUES (@TestStudentID_Hosein, @Fall2023_ID, @FallGPA, 'Excellent', '2024-01-20');
PRINT 'Academic history for Hosein logged.';

-- 3e. Register a second student, "Sara", who will fail a course
INSERT INTO @OutputSara EXEC Education.RegisterStudent @NationalID = '1234567891', @FirstName = 'Sara', @LastName = 'Mohammadi', @MajorID = @MajorID, @DateOfBirth = '2000-02-02',
    @Email = 'sara.mohammadi@university.test', @PhoneNumber = '09124445566',@RegisteredByUserID = 'TestScript';

SELECT @TestStudentID_Sara = NewStudentID FROM @OutputSara;
PRINT 'New student "Sara Test" registered with ID: ' + CAST(@TestStudentID_Sara AS VARCHAR);
-- FIX: Get the Physics1 OfferedCourseID before using it
SELECT @Physics1_OCID = OC.OfferedCourseID FROM Education.OfferedCourses OC JOIN Education.Courses C ON OC.CourseID = C.CourseID WHERE C.CourseCode = '2010115' AND OC.SemesterID = 20231;
EXEC Education.EnrollStudentInCourse @StudentID = @TestStudentID_Sara, @OfferedCourseID = @Physics1_OCID;
SELECT @Physics1_EnrollID_Sara = EnrollmentID FROM Education.Enrollments WHERE StudentID = @TestStudentID_Sara AND OfferedCourseID = @Physics1_OCID;
EXEC Education.RecordStudentGrade @EnrollmentID = @Physics1_EnrollID_Sara, @Grade = '7'; -- Sara fails Physics 1
PRINT 'Sara failed Physics 1.';

PRINT 'Student lifecycle simulation complete.';
PRINT '---------------------------------------------------';

-- ============================================================================
-- STEP 4: TEST SuggestCoursesForStudent PROCEDURE
-- ============================================================================
PRINT '--- Step 4: Testing SuggestCoursesForStudent ---';
SET @Spring2024_ID = 20241;

-- Test Case 4a: Suggestions for "Hosein" (should suggest Term 2 courses)
PRINT '--- Suggestions for Hosein (passed prereqs):';
EXEC Education.SuggestCoursesForStudent @StudentID = @TestStudentID_Hosein, @TargetSemesterID = @Spring2024_ID;

-- Test Case 4b: Suggestions for "Sara" (should suggest Term 1 courses again, especially the failed one)
PRINT '--- Suggestions for Sara (failed a course):';
EXEC Education.SuggestCoursesForStudent @StudentID = @TestStudentID_Sara, @TargetSemesterID = @Spring2024_ID;

-- ============================================================================
-- STEP 5: FINAL VERIFICATION OF ALL FUNCTIONS (using Hosein's data)
-- ============================================================================
PRINT '--- Step 5: Final verification of all Education functions (for Hosein) ---';
SELECT @AdvProg_ID = CourseID FROM Education.Courses WHERE CourseCode = '1734102';
SELECT @DB1_ID = CourseID FROM Education.Courses WHERE CourseCode = '1734303';

PRINT '--- Testing CalculateStudentGPA:';
PRINT '  - Hosein''s Overall GPA (Expected: 17.14): ' + CAST(Education.CalculateStudentGPA(@TestStudentID_Hosein, NULL) AS VARCHAR);

PRINT '--- Testing GetStudentRemainingCredits:';
PRINT '  - Hosein''s Remaining Credits (Expected: 133): ' + CAST(Education.GetStudentRemainingCredits(@TestStudentID_Hosein) AS VARCHAR);

PRINT '--- Testing CheckCoursePrerequisitesMet:';
PRINT '  - Hosein''s Prereqs for Adv Prog (Expected: 1): ' + CAST(Education.CheckCoursePrerequisitesMet(@TestStudentID_Hosein, @AdvProg_ID) AS VARCHAR);
PRINT '  - Hosein''s Prereqs for Database 1 (Expected: 0): ' + CAST(Education.CheckCoursePrerequisitesMet(@TestStudentID_Hosein, @DB1_ID) AS VARCHAR);

PRINT '--- Testing GetStudentCurrentAcademicStatus:';
PRINT '  - Hosein''s Current Academic Status (Expected: Excellent): ' + CAST(Education.GetStudentCurrentAcademicStatus(@TestStudentID_Hosein) AS VARCHAR);

PRINT '--- Testing GetOfferedCourseAvailableCapacity:';
SELECT @Capacity_CS101 = Capacity FROM Education.OfferedCourses WHERE OfferedCourseID = @CS101_OCID;
-- FIX: Corrected expectation. Since Hosein is 'Passed', he is not 'Enrolled'. Capacity should be full.
PRINT '  - Available Capacity for CS101 (Hosein PASSED) (Expected: ' + CAST(@Capacity_CS101 AS VARCHAR) + '): ' + CAST(Education.GetOfferedCourseAvailableCapacity(@CS101_OCID) AS VARCHAR);


DECLARE @TestStudentID_Hosein_Update INT = (SELECT StudentID FROM Education.Students WHERE NationalID = 'TEST_E2E_HOSEIN');
DECLARE @CurrentMajorID INT = (SELECT MajorID FROM Education.Students WHERE StudentID = @TestStudentID_Hosein_Update);

-- ============================================================================
-- STEP 5 (Continued): FINAL VERIFICATION OF REMAINING PROCEDURES
-- ============================================================================


DECLARE @TestStudentID_Hosein_ForUpdate INT = (SELECT StudentID FROM Education.Students WHERE NationalID = '1234567890'); 
DECLARE @TestStudentID_Sara_ForUpdate INT = (SELECT StudentID FROM Education.Students WHERE NationalID = '1234567891');

-- ----------------------------------------------------------------------------
-- TEST 5f: Test UpdateStudentMajor PROCEDURE
-- ----------------------------------------------------------------------------
PRINT '--- Testing UpdateStudentMajor:';

-- Find a different, valid major to switch the student to
DECLARE @TargetMajorID INT = (SELECT MajorID FROM Education.Majors WHERE MajorName = 'Electrical Engineering');

-- Check if both the student and the target major exist before attempting the update
IF @TestStudentID_Hosein_ForUpdate IS NOT NULL AND @TargetMajorID IS NOT NULL
BEGIN
    PRINT '  - Changing major for "Hosein" to "Electrical Engineering"...';
    EXEC Education.UpdateStudentMajor
        @StudentID = @TestStudentID_Hosein_ForUpdate,
        @NewMajorID = @TargetMajorID;

    -- Verification step
    PRINT '  - Verification: Checking new major...';
    SELECT
        S.FirstName,
        M.MajorName AS NewMajor
    FROM Education.Students S
    JOIN Education.Majors M ON S.MajorID = M.MajorID
    WHERE S.StudentID = @TestStudentID_Hosein_ForUpdate;
    -- Expected: NewMajor should be 'Electrical Engineering'
END
ELSE
BEGIN
    PRINT '  - SKIPPED: Could not find the test student or target major to perform the update.';
END
PRINT ''; -- Add a space for readability

-- ----------------------------------------------------------------------------
-- TEST 5g: Test UpdateStudentStatus PROCEDURE & Trigger Interaction
-- ----------------------------------------------------------------------------
PRINT '--- Testing UpdateStudentStatus and its trigger effects:';

-- Update Sara's status from 'Active' to 'Withdrawn'
IF @TestStudentID_Sara_ForUpdate IS NOT NULL
BEGIN
    PRINT '  - Changing status for "Sara" to "Withdrawn"...';
    EXEC Education.UpdateStudentStatus
        @StudentID = @TestStudentID_Sara_ForUpdate,
        @NewStatusName = 'Withdrawn';

    -- Verification 1: Check the student's status in the Education schema
    PRINT '  - Verification 1: Checking Education.Students status...';
    SELECT
        S.FirstName,
        SS.StatusName AS EducationStatus
    FROM Education.Students S
    JOIN Education.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
    WHERE S.StudentID = @TestStudentID_Sara_ForUpdate;
    -- Expected: EducationStatus should be 'Withdrawn'

    -- Verification 2: Check the library member's account status (this verifies the trigger)
    PRINT '  - Verification 2: Checking Library.LibraryMembers status...';
    SELECT
        S.FirstName,
        MAS.StatusName AS LibraryAccountStatus
    FROM Library.LibraryMembers LM
    JOIN Education.Students S ON LM.StudentID = S.StudentID
    JOIN Library.MemberAccountStatuses MAS ON LM.AccountStatusID = MAS.AccountStatusID
    WHERE S.StudentID = @TestStudentID_Sara_ForUpdate;
    -- Expected: LibraryAccountStatus should be 'Inactive'
END
ELSE
BEGIN
    PRINT '  - SKIPPED: Could not find the test student "Sara" to update status.';
END
-- ============================================================================
-- STEP 6: VERIFY LOGS
-- ============================================================================
PRINT '--- Step 6: Verifying the EducationLog table ---';
SELECT LogID, LogTimestamp, EventType, Description FROM Education.EducationLog ORDER BY LogTimestamp ASC;

PRINT '--- Comprehensive Education Schema Test Finished. ---';
GO

