USE Database_project; 
GO

PRINT '--- Starting Comprehensive Security Permissions Test ---';


PRINT '--- Step 1: Creating/Ensuring Test Users and Logins for each role... ---';

-- Admin User
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'AdminTestLogin') CREATE LOGIN AdminTestLogin WITH PASSWORD = 'A_Complex_Password_Admin1!';
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AdminTestUser') CREATE USER AdminTestUser FOR LOGIN AdminTestLogin;
ALTER ROLE EducationAdminRole ADD MEMBER AdminTestUser;

-- Librarian User
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'LibrarianTestLogin') CREATE LOGIN LibrarianTestLogin WITH PASSWORD = 'A_Complex_Password_Librarian1!';
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'LibrarianTestUser') CREATE USER LibrarianTestUser FOR LOGIN LibrarianTestLogin;
ALTER ROLE LibrarianRole ADD MEMBER LibrarianTestUser;

-- Student User
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'StudentTestLogin') CREATE LOGIN StudentTestLogin WITH PASSWORD = 'A_Complex_Password_Student1!';
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'StudentTestUser') CREATE USER StudentTestUser FOR LOGIN StudentTestLogin;
ALTER ROLE StudentRole ADD MEMBER StudentTestUser;

PRINT 'Test users prepared and assigned to roles.';
PRINT '---------------------------------------------------';


--TEST AS EducationAdminRole
PRINT '--- Step 2: Testing as EducationAdminRole ---';
EXECUTE AS USER = 'AdminTestUser';

-- Permitted Action: Register a student
PRINT '  - Attempting to execute RegisterStudent... (should SUCCEED)';
BEGIN TRY
    DECLARE @MajorID_Admin INT = (SELECT TOP 1 MajorID FROM Education.Majors);
    EXEC Education.RegisterStudent @NationalID = '1274597793', @FirstName = 'Admin', @LastName = 'Test', @MajorID = @MajorID_Admin;
    PRINT '    SUCCESS: Admin can register a student.';
END TRY
BEGIN CATCH
    PRINT '    FAILURE: Admin could not register a student. Error: ' + ERROR_MESSAGE();
END CATCH

-- Denied Action: Try to perform a library operation like inserting a book
PRINT '  - Attempting to INSERT into Library.Books... (should FAIL)';
BEGIN TRY
    INSERT INTO Library.Books(ISBN, Title, PublisherID) VALUES ('999-TEST-ADMIN', 'Admin Book', (SELECT TOP 1 PublisherID FROM Library.Publishers));
    PRINT '    FAILURE: Admin was able to insert into Library.Books!';
END TRY
BEGIN CATCH
    PRINT '    SUCCESS: Admin was correctly denied from inserting into Library.Books.';
END CATCH

REVERT; --Revert back to the original user
PRINT 'Admin role tests complete.';
PRINT '---------------------------------------------------';


-- TEST AS LibrarianRole
PRINT '--- Step 3: Testing as LibrarianRole ---';
EXECUTE AS USER = 'LibrarianTestUser';

-- Permitted Action: Perform a library operation (e.g., creating a book)
PRINT '  - Attempting to INSERT into Library.Books... (should SUCCEED)';
BEGIN TRY
    INSERT INTO Library.Books(ISBN, Title, PublisherID) VALUES ('LIBRARIAN-TEST-01', 'Librarian Book', (SELECT TOP 1 PublisherID FROM Library.Publishers));
    PRINT '    SUCCESS: Librarian can insert a book.';
END TRY
BEGIN CATCH
    PRINT '    FAILURE: Librarian could not insert a book. Error: ' + ERROR_MESSAGE();
END CATCH

-- Permitted Action: Select from Students table
PRINT '  - Attempting to SELECT from Education.Students... (should SUCCEED)';
BEGIN TRY
    SELECT TOP 1 StudentID FROM Education.Students;
    PRINT '    SUCCESS: Librarian can select from Students.';
END TRY
BEGIN CATCH
    PRINT '    FAILURE: Librarian was denied from selecting from Students. Error: ' + ERROR_MESSAGE();
END CATCH

-- Denied Action: Try to register a student
PRINT '  - Attempting to execute RegisterStudent... (should FAIL)';
BEGIN TRY
    DECLARE @MajorID_Librarian INT = (SELECT TOP 1 MajorID FROM Education.Majors);
    EXEC Education.RegisterStudent @NationalID = 'LIBRARIAN_TEST_01', @FirstName = 'Librarian', @LastName = 'Test', @MajorID = @MajorID_Librarian;
    PRINT '    FAILURE: Librarian was able to register a student!';
END TRY
BEGIN CATCH
    PRINT '    SUCCESS: Librarian was correctly denied from registering a student.';
END CATCH

REVERT;
PRINT 'Librarian role tests complete.';
PRINT '---------------------------------------------------';


-- TEST AS StudentRole
PRINT '--- Step 4: Testing as StudentRole ---';
EXECUTE AS USER = 'StudentTestUser';

-- Permitted Action: Select from a public table
PRINT '  - Attempting to SELECT from Education.Courses... (should SUCCEED)';
BEGIN TRY
    SELECT TOP 1 CourseName FROM Education.Courses;
    PRINT '    SUCCESS: Student can select from Courses.';
END TRY
BEGIN CATCH
    PRINT '    FAILURE: Student could not select from Courses. Error: ' + ERROR_MESSAGE();
END CATCH

-- Denied Action: Directly INSERT into Enrollments
PRINT '  - Attempting to INSERT into Education.Enrollments... (should FAIL)';
BEGIN TRY
    INSERT INTO Education.Enrollments(StudentID, OfferedCourseID, EnrollmentStatusID) VALUES (1, 1, 1);
    PRINT '    FAILURE: Student was able to insert into Enrollments directly!';
END TRY
BEGIN CATCH
    PRINT '    SUCCESS: Student was correctly denied from inserting into Enrollments.';
END CATCH

-- Permitted Action
PRINT '  - Attempting to execute CalculateStudentGPA directly... (should SUCCEED)';
DECLARE @AnyStudentID INT = (SELECT TOP 1 StudentID FROM Education.Students);
BEGIN TRY
    IF @AnyStudentID IS NOT NULL
    BEGIN
        SELECT Education.CalculateStudentGPA(@AnyStudentID, NULL);
        PRINT '    SUCCESS: Student can execute the GPA function.';
    END
    ELSE
    BEGIN
        PRINT '    SKIPPED: Could not find a student ID to test with.';
    END
END TRY
BEGIN CATCH
    PRINT '    FAILURE: Student was denied from executing the GPA function. Error: ' + ERROR_MESSAGE();
END CATCH

REVERT;
PRINT 'Student role tests complete.';
PRINT '---------------------------------------------------';


-- CLEAN UP TEST USERS AND LOGINS
PRINT '--- Step 5: Cleaning up test users and logins... ---';
-- Drop users from the database first
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AdminTestUser') DROP USER AdminTestUser;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'LibrarianTestUser') DROP USER LibrarianTestUser;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'StudentTestUser') DROP USER StudentTestUser;
-- Drop logins from the server
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'AdminTestLogin') DROP LOGIN AdminTestLogin;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'LibrarianTestLogin') DROP LOGIN LibrarianTestLogin;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'StudentTestLogin') DROP LOGIN StudentTestLogin;
-- Clean up test data created by this script
DELETE FROM Library.Books WHERE ISBN IN ('999-TEST-ADMIN', 'LIBRARIAN-TEST-01');
DELETE FROM Education.Students WHERE NationalID = '1274597793';

PRINT '--- Security Permissions Test Finished ---';
GO