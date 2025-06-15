GRANT CONTROL ON SCHEMA :: Education TO EducationAdminRole;
GRANT SELECT ON SCHEMA :: Library TO EducationAdminRole;
GRANT EXECUTE ON Education.RegisterStudent TO EducationAdminRole;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: Library TO LibrarianRole;
GRANT EXECUTE ON SCHEMA :: Library TO LibrarianRole;
GRANT SELECT ON Education.Students TO LibrarianRole;
GRANT SELECT ON Education.Majors TO LibrarianRole;
GRANT SELECT ON Education.StudentStatuses TO LibrarianRole;
DENY EXECUTE ON Education.RegisterStudent TO LibrarianRole;


GRANT SELECT ON Education.Courses TO StudentRole;
GRANT SELECT ON Education.Majors TO StudentRole;
GRANT SELECT ON Education.Departments TO StudentRole;
GRANT SELECT ON Education.Semesters TO StudentRole;
GRANT SELECT ON Education.Professors TO StudentRole;
GRANT SELECT ON Education.OfferedCourses TO StudentRole;
GRANT SELECT ON Education.Curriculum TO StudentRole;
GRANT SELECT ON Library.Books TO StudentRole;
GRANT SELECT ON Library.Authors TO StudentRole;
GRANT SELECT ON Library.Publishers TO StudentRole;
GRANT SELECT ON Library.Categories TO StudentRole;
GRANT SELECT ON Library.BookCopies TO StudentRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA :: Education TO StudentRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA :: Library TO StudentRole;

DENY EXECUTE ON Education.RegisterStudent TO StudentRole;

