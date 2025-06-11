IF OBJECT_ID('Education.Students', 'U') IS NULL
CREATE TABLE [Education].[Students] (
  [StudentID] int PRIMARY KEY IDENTITY(1, 1),
  [NationalID] varchar(20) UNIQUE NOT NULL,
  [FirstName] nvarchar(100) NOT NULL,
  [LastName] nvarchar(100) NOT NULL,
  [DateOfBirth] date,
  [EnrollmentDate] date NOT NULL,
  [MajorID] int NOT NULL,
  [StudentStatusID] int NOT NULL,
  [Email] varchar(255) UNIQUE,
  [PhoneNumber] varchar(20)
)
GO

IF OBJECT_ID('Education.StudentStatuses', 'U') IS NULL
CREATE TABLE [Education].[StudentStatuses] (
  [StudentStatusID] int PRIMARY KEY IDENTITY(1, 1),
  [StatusName] nvarchar(50) UNIQUE NOT NULL
)
GO


IF OBJECT_ID('Education.Professors', 'U') IS NULL
CREATE TABLE [Education].[Professors] (
  [ProfessorID] int PRIMARY KEY IDENTITY(1, 1),
  [FirstName] nvarchar(100) NOT NULL,
  [LastName] nvarchar(100) NOT NULL,
  [DepartmentID] int NOT NULL,
  [Email] varchar(255) UNIQUE,
  [OfficeLocation] nvarchar(100)
)
GO

IF OBJECT_ID('Education.Departments', 'U') IS NULL
CREATE TABLE [Education].[Departments] (
  [DepartmentID] int PRIMARY KEY IDENTITY(1, 1),
  [DepartmentName] nvarchar(100) UNIQUE NOT NULL
)
GO

IF OBJECT_ID('Education.DepartmentHead', 'U') IS NULL
CREATE TABLE [Education].[DepartmentHead] (
  [DepartmentID] int NOT NULL,
  [ProfessorID] int NOT NULL
)
GO

IF OBJECT_ID('Education.Majors', 'U') IS NULL
CREATE TABLE [Education].[Majors] (
  [MajorID] int PRIMARY KEY IDENTITY(1, 1),
  [MajorName] nvarchar(100) UNIQUE NOT NULL,
  [DepartmentID] int NOT NULL,
  [RequiredCredits] int
)
GO

IF OBJECT_ID('Education.Courses', 'U') IS NULL
CREATE TABLE [Education].[Courses] (
  [CourseID] int PRIMARY KEY IDENTITY(1, 1),
  [CourseCode] varchar(20) UNIQUE NOT NULL,
  [CourseName] nvarchar(150) NOT NULL,
  [Credits] int NOT NULL,
  [DepartmentID] int NOT NULL,
  [Description] ntext
)
GO

IF OBJECT_ID('Education.Semesters', 'U') IS NULL
CREATE TABLE [Education].[Semesters] (
  [SemesterID] int PRIMARY KEY,
  [SemesterName] nvarchar(50) NOT NULL,
  [StartDate] date NOT NULL,
  [EndDate] date NOT NULL,
  [IsCurrentSemester] bit DEFAULT (0)
)
GO

IF OBJECT_ID('Education.OfferedCourses', 'U') IS NULL
CREATE TABLE [Education].[OfferedCourses] (
  [OfferedCourseID] int PRIMARY KEY IDENTITY(1, 1),
  [CourseID] int NOT NULL,
  [ProfessorID] int,
  [SemesterID] int NOT NULL,
  [Capacity] int,
  [RoomID] int NOT NULL,
  [ScheduleInfo] nvarchar(200)
)
GO

IF OBJECT_ID('Education.Buildings', 'U') IS NULL
CREATE TABLE [Education].[Buildings] (
  [BuildingID] int PRIMARY KEY IDENTITY(1, 1),
  [BuildingName] nvarchar(100) UNIQUE NOT NULL,
  [Address] nvarchar(255)
)
GO

IF OBJECT_ID('Education.Rooms', 'U') IS NULL
CREATE TABLE [Education].[Rooms] (
  [RoomID] int PRIMARY KEY IDENTITY(1, 1),
  [BuildingID] int NOT NULL,
  [RoomNumber] varchar(20) NOT NULL,
  [RoomCapacity] int,
  [RoomType] nvarchar(50)
)
GO

IF OBJECT_ID('Education.Enrollments', 'U') IS NULL
CREATE TABLE [Education].[Enrollments] (
  [EnrollmentID] int PRIMARY KEY IDENTITY(1, 1),
  [StudentID] int NOT NULL,
  [OfferedCourseID] int NOT NULL,
  [EnrollmentDate] datetime NOT NULL DEFAULT (GETDATE()),
  [Grade] nvarchar(10),
  [EnrollmentStatusID] int NOT NULL
)
GO

IF OBJECT_ID('Education.EnrollmentStatuses', 'U') IS NULL
CREATE TABLE [Education].[EnrollmentStatuses] (
  [EnrollmentStatusID] int PRIMARY KEY IDENTITY(1, 1),
  [StatusName] nvarchar(50) UNIQUE NOT NULL
)
GO

IF OBJECT_ID('Education.Prerequisites', 'U') IS NULL
CREATE TABLE [Education].[Prerequisites] (
  [CourseID] int,
  [PrerequisiteCourseID] int,
  PRIMARY KEY ([CourseID], [PrerequisiteCourseID])
)
GO

IF OBJECT_ID('Education.Curriculum', 'U') IS NULL
CREATE TABLE [Education].[Curriculum] (
  [CurriculumID] int PRIMARY KEY IDENTITY(1, 1),
  [MajorID] int NOT NULL,
  [CourseID] int NOT NULL,
  [SuggestedTerm] int NOT NULL,
  [IsCoreRequirement] bit DEFAULT (1),
  [Priority] int DEFAULT (0)
)
GO

IF OBJECT_ID('Education.StudentAcademicHistory', 'U') IS NULL
CREATE TABLE [Education].[StudentAcademicHistory] (
  [HistoryID] int PRIMARY KEY IDENTITY(1, 1),
  [StudentID] int NOT NULL,
  [SemesterID] int NOT NULL,
  [GPA] decimal(3,2),
  [AcademicStatus] nvarchar(50),
  [StatusDate] date NOT NULL,
  [Notes] ntext
)
GO

IF OBJECT_ID('Education.EducationLog', 'U') IS NULL
CREATE TABLE [Education].[EducationLog] (
  [LogID] bigint PRIMARY KEY IDENTITY(1, 1),
  [LogTimestamp] datetime NOT NULL DEFAULT (GETDATE()),
  [EventType] nvarchar(100) NOT NULL,
  [Description] ntext,
  [AffectedTable] nvarchar(128),
  [AffectedRecordID] varchar(255),
  [UserID] nvarchar(128)
)
GO

IF OBJECT_ID('Library.LibraryMembers', 'U') IS NULL
CREATE TABLE [Library].[LibraryMembers] (
  [MemberID] int PRIMARY KEY IDENTITY(1, 1),
  [StudentID] int UNIQUE NOT NULL,
  [LibraryCardNumber] varchar(50) UNIQUE NOT NULL,
  [RegistrationDate] date NOT NULL DEFAULT (GETDATE()),
  [AccountStatusID] int NOT NULL,
  [Notes] ntext
)
GO

IF OBJECT_ID('Library.MemberAccountStatuses', 'U') IS NULL
CREATE TABLE [Library].[MemberAccountStatuses] (
  [AccountStatusID] int PRIMARY KEY IDENTITY(1, 1),
  [StatusName] nvarchar(50) UNIQUE NOT NULL
)
GO

IF OBJECT_ID('Library.Books', 'U') IS NULL
CREATE TABLE [Library].[Books] (
  [BookID] int PRIMARY KEY IDENTITY(1, 1),
  [ISBN] varchar(20) UNIQUE NOT NULL,
  [Title] nvarchar(255) NOT NULL,
  [PublicationYear] int,
  [PublisherID] int NOT NULL,
  [Edition] nvarchar(50),
  [Description] ntext,
  [CoverImageURL] varchar(500)
)
GO

IF OBJECT_ID('Library.Authors', 'U') IS NULL
CREATE TABLE [Library].[Authors] (
  [AuthorID] int PRIMARY KEY IDENTITY(1, 1),
  [FirstName] nvarchar(100) NOT NULL,
  [LastName] nvarchar(100),
  [Biography] ntext
)
GO

IF OBJECT_ID('Library.Publishers', 'U') IS NULL
CREATE TABLE [Library].[Publishers] (
  [PublisherID] int PRIMARY KEY IDENTITY(1, 1),
  [PublisherName] nvarchar(150) UNIQUE NOT NULL,
  [Country] nvarchar(100),
  [Website] varchar(255)
)
GO

IF OBJECT_ID('Library.Categories', 'U') IS NULL
CREATE TABLE [Library].[Categories] (
  [CategoryID] int PRIMARY KEY IDENTITY(1, 1),
  [CategoryName] nvarchar(100) UNIQUE NOT NULL,
  [Description] ntext
)
GO

IF OBJECT_ID('Library.BookCopies', 'U') IS NULL
CREATE TABLE [Library].[BookCopies] (
  [CopyID] int PRIMARY KEY IDENTITY(1, 1),
  [BookID] int NOT NULL,
  [AcquisitionDate] date NOT NULL,
  [CopyStatusID] int NOT NULL,
  [LocationInLibrary] nvarchar(100),
  [PurchasePrice] decimal(10,2)
)
GO

IF OBJECT_ID('Library.BookCopyStatuses', 'U') IS NULL
CREATE TABLE [Library].[BookCopyStatuses] (
  [CopyStatusID] int PRIMARY KEY IDENTITY(1, 1),
  [StatusName] nvarchar(50) UNIQUE NOT NULL
)
GO


IF OBJECT_ID('Library.BookAuthors', 'U') IS NULL
CREATE TABLE [Library].[BookAuthors] (
  [BookID] int,
  [AuthorID] int,
  [AuthorRole] nvarchar(50),
  PRIMARY KEY ([BookID], [AuthorID])
)
GO

IF OBJECT_ID('Library.BookCategories', 'U') IS NULL
CREATE TABLE [Library].[BookCategories] (
  [BookID] int,
  [CategoryID] int,
  PRIMARY KEY ([BookID], [CategoryID])
)
GO

IF OBJECT_ID('Library.Loans', 'U') IS NULL
CREATE TABLE [Library].[Loans] (
  [LoanID] bigint PRIMARY KEY IDENTITY(1, 1),
  [CopyID] int NOT NULL,
  [MemberID] int NOT NULL,
  [LoanDate] datetime NOT NULL DEFAULT (GETDATE()),
  [DueDate] datetime NOT NULL,
  [ReturnDate] datetime,
  [FinesApplied] decimal(10,2) DEFAULT (0),
  [Notes] ntext
)
GO

IF OBJECT_ID('Library.LibraryLog', 'U') IS NULL
CREATE TABLE [Library].[LibraryLog] (
  [LogID] bigint PRIMARY KEY IDENTITY(1, 1),
  [LogTimestamp] datetime NOT NULL DEFAULT (GETDATE()),
  [EventType] nvarchar(100) NOT NULL,
  [Description] ntext,
  [AffectedTable] nvarchar(128),
  [AffectedRecordID] varchar(255),
  [UserID] nvarchar(128)
)
GO


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Students_Major') AND parent_object_id = OBJECT_ID(N'Education.Students'))
ALTER TABLE [Education].[Students] ADD CONSTRAINT FK_Students_Major FOREIGN KEY ([MajorID]) REFERENCES [Education].[Majors] ([MajorID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Students_StudentStatus') AND parent_object_id = OBJECT_ID(N'Education.Students'))
ALTER TABLE [Education].[Students] ADD CONSTRAINT FK_Students_StudentStatus FOREIGN KEY ([StudentStatusID]) REFERENCES [Education].[StudentStatuses] ([StudentStatusID]) ON DELETE NO ACTION ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Professors_Department') AND parent_object_id = OBJECT_ID(N'Education.Professors'))
ALTER TABLE [Education].[Professors] ADD CONSTRAINT FK_Professors_Department FOREIGN KEY ([DepartmentID]) REFERENCES [Education].[Departments] ([DepartmentID]) ON DELETE NO ACTION ON UPDATE NO ACTION;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_DepartmentHead_Department') AND parent_object_id = OBJECT_ID(N'Education.DepartmentHead'))
BEGIN
    ALTER TABLE Education.DepartmentHead
    ADD CONSTRAINT FK_DepartmentHead_Department FOREIGN KEY ([DepartmentID]) REFERENCES Education.Departments([DepartmentID]) ON DELETE CASCADE ON UPDATE CASCADE;
END
GO


IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_DepartmentHead_Professor') AND parent_object_id = OBJECT_ID(N'Education.DepartmentHead'))
BEGIN
    ALTER TABLE Education.DepartmentHead
    ADD CONSTRAINT FK_DepartmentHead_Professor FOREIGN KEY ([ProfessorID]) REFERENCES Education.Professors([ProfessorID]) ON DELETE NO ACTION ON UPDATE NO ACTION; 
END
GO

IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE object_id = OBJECT_ID(N'UQ_DepartmentHead_Department') AND type = 'UQ')
BEGIN
    ALTER TABLE Education.DepartmentHead
    ADD CONSTRAINT UQ_DepartmentHead_Department UNIQUE ([DepartmentID]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE object_id = OBJECT_ID(N'UQ_DepartmentHead_Professor') AND type = 'UQ')
BEGIN
    ALTER TABLE Education.DepartmentHead
    ADD CONSTRAINT UQ_DepartmentHead_Professor UNIQUE ([ProfessorID]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Majors_Department') AND parent_object_id = OBJECT_ID(N'Education.Majors'))
ALTER TABLE [Education].[Majors] ADD CONSTRAINT FK_Majors_Department FOREIGN KEY ([DepartmentID]) REFERENCES [Education].[Departments] ([DepartmentID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Courses_Department') AND parent_object_id = OBJECT_ID(N'Education.Courses'))
ALTER TABLE [Education].[Courses] ADD CONSTRAINT FK_Courses_Department FOREIGN KEY ([DepartmentID]) REFERENCES [Education].[Departments] ([DepartmentID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_OfferedCourses_Course') AND parent_object_id = OBJECT_ID(N'Education.OfferedCourses'))
ALTER TABLE [Education].[OfferedCourses] ADD CONSTRAINT FK_OfferedCourses_Course FOREIGN KEY ([CourseID]) REFERENCES [Education].[Courses] ([CourseID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_OfferedCourses_Professor') AND parent_object_id = OBJECT_ID(N'Education.OfferedCourses'))
ALTER TABLE [Education].[OfferedCourses] ADD CONSTRAINT FK_OfferedCourses_Professor FOREIGN KEY ([ProfessorID]) REFERENCES [Education].[Professors] ([ProfessorID]) ON DELETE SET NULL ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_OfferedCourses_Semester') AND parent_object_id = OBJECT_ID(N'Education.OfferedCourses'))
ALTER TABLE [Education].[OfferedCourses] ADD CONSTRAINT FK_OfferedCourses_Semester FOREIGN KEY ([SemesterID]) REFERENCES [Education].[Semesters] ([SemesterID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_OfferedCourses_Room') AND parent_object_id = OBJECT_ID(N'Education.OfferedCourses'))
ALTER TABLE [Education].[OfferedCourses] ADD CONSTRAINT FK_OfferedCourses_Room FOREIGN KEY ([RoomID]) REFERENCES [Education].[Rooms] ([RoomID]) ON DELETE NO ACTION ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Rooms_Building') AND parent_object_id = OBJECT_ID(N'Education.Rooms'))
ALTER TABLE [Education].[Rooms] ADD CONSTRAINT FK_Rooms_Building FOREIGN KEY ([BuildingID]) REFERENCES [Education].[Buildings] ([BuildingID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Enrollments_Student') AND parent_object_id = OBJECT_ID(N'Education.Enrollments'))
ALTER TABLE [Education].[Enrollments] ADD CONSTRAINT FK_Enrollments_Student FOREIGN KEY ([StudentID]) REFERENCES [Education].[Students] ([StudentID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Enrollments_OfferedCourse') AND parent_object_id = OBJECT_ID(N'Education.Enrollments'))
ALTER TABLE [Education].[Enrollments] ADD CONSTRAINT FK_Enrollments_OfferedCourse FOREIGN KEY ([OfferedCourseID]) REFERENCES [Education].[OfferedCourses] ([OfferedCourseID]) ON DELETE NO ACTION ON UPDATE NO ACTION; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Enrollments_EnrollmentStatus') AND parent_object_id = OBJECT_ID(N'Education.Enrollments'))
ALTER TABLE [Education].[Enrollments] ADD CONSTRAINT FK_Enrollments_EnrollmentStatus FOREIGN KEY ([EnrollmentStatusID]) REFERENCES [Education].[EnrollmentStatuses] ([EnrollmentStatusID]) ON DELETE NO ACTION ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Prerequisites_Course') AND parent_object_id = OBJECT_ID(N'Education.Prerequisites'))
ALTER TABLE [Education].[Prerequisites] ADD CONSTRAINT FK_Prerequisites_Course FOREIGN KEY ([CourseID]) REFERENCES [Education].[Courses] ([CourseID]) ON DELETE NO ACTION ON UPDATE NO ACTION; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Prerequisites_PrerequisiteCourse') AND parent_object_id = OBJECT_ID(N'Education.Prerequisites'))
ALTER TABLE [Education].[Prerequisites] ADD CONSTRAINT FK_Prerequisites_PrerequisiteCourse FOREIGN KEY ([PrerequisiteCourseID]) REFERENCES [Education].[Courses] ([CourseID]) ON DELETE NO ACTION ON UPDATE NO ACTION; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Curriculum_Major') AND parent_object_id = OBJECT_ID(N'Education.Curriculum'))
ALTER TABLE [Education].[Curriculum] ADD CONSTRAINT FK_Curriculum_Major FOREIGN KEY ([MajorID]) REFERENCES [Education].[Majors] ([MajorID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Curriculum_Course') AND parent_object_id = OBJECT_ID(N'Education.Curriculum'))
ALTER TABLE [Education].[Curriculum] ADD CONSTRAINT FK_Curriculum_Course FOREIGN KEY ([CourseID]) REFERENCES [Education].[Courses] ([CourseID]) ON DELETE NO ACTION ON UPDATE NO ACTION; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_StudentAcademicHistory_Student') AND parent_object_id = OBJECT_ID(N'Education.StudentAcademicHistory'))
ALTER TABLE [Education].[StudentAcademicHistory] ADD CONSTRAINT FK_StudentAcademicHistory_Student FOREIGN KEY ([StudentID]) REFERENCES [Education].[Students] ([StudentID]) ON DELETE CASCADE ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_StudentAcademicHistory_Semester') AND parent_object_id = OBJECT_ID(N'Education.StudentAcademicHistory'))
ALTER TABLE [Education].[StudentAcademicHistory] ADD CONSTRAINT FK_StudentAcademicHistory_Semester FOREIGN KEY ([SemesterID]) REFERENCES [Education].[Semesters] ([SemesterID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_LibraryMembers_Student') AND parent_object_id = OBJECT_ID(N'Library.LibraryMembers'))
ALTER TABLE [Library].[LibraryMembers] ADD CONSTRAINT FK_LibraryMembers_Student FOREIGN KEY ([StudentID]) REFERENCES [Education].[Students] ([StudentID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_LibraryMembers_AccountStatus') AND parent_object_id = OBJECT_ID(N'Library.LibraryMembers'))
ALTER TABLE [Library].[LibraryMembers] ADD CONSTRAINT FK_LibraryMembers_AccountStatus FOREIGN KEY ([AccountStatusID]) REFERENCES [Library].[MemberAccountStatuses] ([AccountStatusID]) ON DELETE NO ACTION ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Books_Publisher') AND parent_object_id = OBJECT_ID(N'Library.Books'))
ALTER TABLE [Library].[Books] ADD CONSTRAINT FK_Books_Publisher FOREIGN KEY ([PublisherID]) REFERENCES [Library].[Publishers] ([PublisherID]) ON DELETE NO ACTION ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookCopies_Book') AND parent_object_id = OBJECT_ID(N'Library.BookCopies'))
ALTER TABLE [Library].[BookCopies] ADD CONSTRAINT FK_BookCopies_Book FOREIGN KEY ([BookID]) REFERENCES [Library].[Books] ([BookID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookCopies_CopyStatus') AND parent_object_id = OBJECT_ID(N'Library.BookCopies'))
ALTER TABLE [Library].[BookCopies] ADD CONSTRAINT FK_BookCopies_CopyStatus FOREIGN KEY ([CopyStatusID]) REFERENCES [Library].[BookCopyStatuses] ([CopyStatusID]) ON DELETE NO ACTION ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookAuthors_Book') AND parent_object_id = OBJECT_ID(N'Library.BookAuthors'))
ALTER TABLE [Library].[BookAuthors] ADD CONSTRAINT FK_BookAuthors_Book FOREIGN KEY ([BookID]) REFERENCES [Library].[Books] ([BookID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookAuthors_Author') AND parent_object_id = OBJECT_ID(N'Library.BookAuthors'))
ALTER TABLE [Library].[BookAuthors] ADD CONSTRAINT FK_BookAuthors_Author FOREIGN KEY ([AuthorID]) REFERENCES [Library].[Authors] ([AuthorID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookCategories_Book') AND parent_object_id = OBJECT_ID(N'Library.BookCategories'))
ALTER TABLE [Library].[BookCategories] ADD CONSTRAINT FK_BookCategories_Book FOREIGN KEY ([BookID]) REFERENCES [Library].[Books] ([BookID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_BookCategories_Category') AND parent_object_id = OBJECT_ID(N'Library.BookCategories'))
ALTER TABLE [Library].[BookCategories] ADD CONSTRAINT FK_BookCategories_Category FOREIGN KEY ([CategoryID]) REFERENCES [Library].[Categories] ([CategoryID]) ON DELETE CASCADE ON UPDATE CASCADE;
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Loans_BookCopy') AND parent_object_id = OBJECT_ID(N'Library.Loans'))
ALTER TABLE [Library].[Loans] ADD CONSTRAINT FK_Loans_BookCopy FOREIGN KEY ([CopyID]) REFERENCES [Library].[BookCopies] ([CopyID]) ON DELETE NO ACTION ON UPDATE CASCADE; 
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'FK_Loans_LibraryMember') AND parent_object_id = OBJECT_ID(N'Library.Loans'))
ALTER TABLE [Library].[Loans] ADD CONSTRAINT FK_Loans_LibraryMember FOREIGN KEY ([MemberID]) REFERENCES [Library].[LibraryMembers] ([MemberID]) ON DELETE NO ACTION ON UPDATE CASCADE;
GO
