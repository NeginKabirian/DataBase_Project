USE Database_project;
GO


BEGIN TRY
    INSERT INTO Education.Departments (DepartmentName) VALUES
    ('Computer Engineering'),
    ('Electrical Engineering'),
    ('Basic Sciences'),
    ('Humanities & General Education'); 
    PRINT 'Departments seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Departments: ' + ERROR_MESSAGE();
    RETURN; 
END CATCH
GO

BEGIN TRY
    INSERT INTO Education.Buildings (BuildingName, Address) VALUES
    ('Main Engineering Building', '1 University Isfahan of Technology street'),
    ('Science Faculty', '2 Science street'),
    ('Central Library Building', '3 Library street'),
    ('Sports Complex', '4 Sports street');
    PRINT 'Buildings seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Buildings: ' + ERROR_MESSAGE();
    RETURN; 
END CATCH
GO

BEGIN TRY
    INSERT INTO Education.StudentStatuses (StatusName) VALUES
    ('Active'),         
    ('Graduated'),       
    ('Withdrawn'),      
    ('Expelled'),       
    ('On Leave'),       
    ('Probation');      
    PRINT 'Student Statuses seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Student Statuses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    INSERT INTO Education.EnrollmentStatuses (StatusName) VALUES
    ('Enrolled'),         
    ('Passed'),          
    ('Failed'),          
    ('Dropped'),       
    ('Transferred Credit'); 
    PRINT 'Enrollment Statuses seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Enrollment Statuses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    INSERT INTO Library.MemberAccountStatuses (StatusName) VALUES
    ('Active'),         
    ('Inactive'),         
    ('Suspended'),       
    ('Blocked');         
    PRINT 'Library Member Account Statuses seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Library Member Account Statuses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    INSERT INTO Library.BookCopyStatuses (StatusName) VALUES
    ('Available'),       
    ('Borrowed'),      
    ('Damaged'),        
    ('Lost'),             
    ('In Repair');       
    PRINT 'Book Copy Statuses seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Book Copy Statuses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    INSERT INTO Education.Semesters (SemesterID, SemesterName, StartDate, EndDate, IsCurrentSemester) VALUES
    (20231, 'Fall 2023', '2023-09-23', '2024-01-20', 0),
    (20241, 'Spring 2024', '2024-02-06', '2024-06-15', 1),
    (20242, 'Summer 2024', '2024-07-01', '2024-08-30', 0),
    (20251, 'Fall 2024', '2024-09-22', '2025-01-18', 0); 
    PRINT 'Semesters seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Semesters: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    INSERT INTO Library.Authors (FirstName, LastName, Biography) VALUES
    ('Martin', 'Fowler', 'Renowned author on software development and architecture.'),
    ('Irvin', 'Yalom', 'American existential psychiatrist, psychotherapist, and author.'),
    ('Mahmoud', 'Dowlatabadi', 'Prominent Iranian writer and novelist.'),
    ('Robert C.', 'Martin', 'Author of "Clean Code" and "Agile Software Development".');
    PRINT 'Authors seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Authors: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO


BEGIN TRY
    INSERT INTO Library.Publishers (PublisherName, Country, Website) VALUES
    ('O''Reilly Media', 'USA', 'https://www.oreilly.com/'),
    ('Cheshmeh Publishing', 'Iran', 'https://www.cheshmeh.ir/'),
    ('Penguin Random House', 'USA', 'https://global.penguinrandomhouse.com/');
    PRINT 'Publishers seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Publishers: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO


BEGIN TRY
    INSERT INTO Library.Categories (CategoryName, Description) VALUES
    ('Computer Science', 'Books related to computer programming, algorithms, and theory.'),
    ('Software Engineering', 'Books on software development methodologies and practices.'),
    ('Psychology', 'Books on human mind and behavior.'),
    ('Philosophy', 'Books on fundamental nature of knowledge, reality, and existence.'),
    ('Iranian Literature', 'Novels and stories by Iranian authors.'),
    ('Fiction', 'General fiction novels.'),
    ('Science', 'General science topics.');
    PRINT 'Categories seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Categories: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    DECLARE @CompEngDeptID_Major INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Computer Engineering');
    DECLARE @ElecEngDeptID_Major INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Electrical Engineering');

    INSERT INTO Education.Majors (MajorName, DepartmentID, RequiredCredits) VALUES
    ('Computer Engineering', @CompEngDeptID_Major, 140),
    ('Electrical Engineering', @ElecEngDeptID_Major, 140);
    PRINT 'Majors seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Majors: ' + ERROR_MESSAGE();
    RETURN;
END CATCH


BEGIN TRY
    DECLARE @MainEngBuildingID INT = (SELECT BuildingID FROM Education.Buildings WHERE BuildingName = 'Main Engineering Building');
    DECLARE @ScienceBuildingID INT = (SELECT BuildingID FROM Education.Buildings WHERE BuildingName = 'Science Faculty');
    DECLARE @LibraryBuildingID INT = (SELECT BuildingID FROM Education.Buildings WHERE BuildingName = 'Central Library Building');

    INSERT INTO Education.Rooms (BuildingID, RoomNumber, RoomCapacity, RoomType) VALUES
    (@MainEngBuildingID, 'E-101', 50, 'Classroom'),
    (@MainEngBuildingID, 'E-102', 50, 'Classroom'),
    (@MainEngBuildingID, 'E-203', 30, 'Computer Lab'),
    (@MainEngBuildingID, 'E-205', 30, 'Hardware Lab'),
    (@ScienceBuildingID, 'S-300', 120, 'Lecture Hall'),
    (@ScienceBuildingID, 'S-110', 80, 'Classroom'),
    (@LibraryBuildingID, 'Lib-Study1', 20, 'Study Room'),
    (@LibraryBuildingID, 'Lib-MainHall', 200, 'Reading Hall');
    PRINT 'Rooms seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Rooms: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    DECLARE @CompEngDeptID_Prof INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Computer Engineering');
    DECLARE @ElecEngDeptID_Prof INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Electrical Engineering');
    DECLARE @BasicSciDeptID_Prof INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Basic Sciences');

    INSERT INTO Education.Professors (FirstName, LastName, DepartmentID, Email, OfficeLocation) VALUES
    ('Nader', 'Karimi', @CompEngDeptID_Prof, 'n.karimi@university.com', 'E-310'),
    ('Shirin', 'Baghooli', @CompEngDeptID_Prof, 's.baghool@university.com', 'E-312'),
    ('Sajad', 'Mari', @BasicSciDeptID_Prof, 's.mari@university.com', 'S-201'),
    ('Dr', 'Taban', @ElecEngDeptID_Prof, 'd.taban@university.com', 'E-405'),
    ('Zeinab', 'Maleki', @CompEngDeptID_Prof, 'z.maleki@university.com', 'E-308');
    PRINT 'Professors seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Professors: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    DECLARE @OReillyPublisherID INT = (SELECT PublisherID FROM Library.Publishers WHERE PublisherName = 'O''Reilly Media');
    DECLARE @CheshmehPublisherID INT = (SELECT PublisherID FROM Library.Publishers WHERE PublisherName = 'Cheshmeh Publishing');
    DECLARE @PenguinPublisherID INT = (SELECT PublisherID FROM Library.Publishers WHERE PublisherName = 'Penguin Random House');

    INSERT INTO Library.Books (ISBN, Title, PublicationYear, PublisherID, Edition, Description) VALUES
    ('978-0321125217', 'Refactoring: Improving the Design of Existing Code', 1999, @OReillyPublisherID, '1st Edition', 'A classic book on refactoring techniques.'),
    ('978-0321765723', 'The Lord of the Rings', 1954, @PenguinPublisherID, 'Reissue', 'Epic high-fantasy novel.'),
    ('978-6002291334', 'When Nietzsche Wept', 1992, @CheshmehPublisherID, '1st Iranian Ed.', 'A philosophical novel by Irvin Yalom.'),
    ('978-9643052849', 'Kelidar', 1984, @CheshmehPublisherID, 'Complete Edition', 'A monumental novel of Iranian literature by Mahmoud Dowlatabadi.'),
    ('978-0596007126', 'Head First Java', 2003, @OReillyPublisherID, '2nd Edition', 'A visually rich book for learning Java.'),
    ('978-0132350884', 'Clean Code: A Handbook of Agile Software Craftsmanship', 2008, @PenguinPublisherID, '1st Edition', 'Principles of writing good code by Robert C. Martin.');
    PRINT 'Books seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Books: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO


BEGIN TRY
    DECLARE @CompEngDeptID_Head INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Computer Engineering');
    DECLARE @ElecEngDeptID_Head INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Electrical Engineering');
    
   
    DECLARE @ProfNaderID_Head INT = (SELECT ProfessorID FROM Education.Professors WHERE Email = 'n.karimi@university.com');
    DECLARE @ProfTabanID_Head INT = (SELECT ProfessorID FROM Education.Professors WHERE Email = 'd.taban@university.com'); 

    IF @CompEngDeptID_Head IS NOT NULL AND @ProfNaderID_Head IS NOT NULL
        INSERT INTO Education.DepartmentHead (DepartmentID, ProfessorID) VALUES (@CompEngDeptID_Head, @ProfNaderID_Head);
    IF @ElecEngDeptID_Head IS NOT NULL AND @ProfTabanID_Head IS NOT NULL
        INSERT INTO Education.DepartmentHead (DepartmentID, ProfessorID) VALUES (@ElecEngDeptID_Head, @ProfTabanID_Head);
    PRINT 'Department Heads seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Department Heads: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    -- Get Department IDs
    DECLARE @CompEngDeptID_Course INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Computer Engineering');
    DECLARE @ElecEngDeptID_Course INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Electrical Engineering');
    DECLARE @BasicSciDeptID_Course INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Basic Sciences');
    DECLARE @GeneralDeptID_Course INT = (SELECT DepartmentID FROM Education.Departments WHERE DepartmentName = 'Humanities & General Education');

    -- Term 1
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1914101', 'General Mathematics 1', 3, @BasicSciDeptID_Course), ('2010115', 'Physics 1', 3, @BasicSciDeptID_Course), ('1730115', 'Computer Programming Fundamentals & Lab', 4, @CompEngDeptID_Course), ('1730101', 'Computer Workshop', 1, @CompEngDeptID_Course), ('1730103', 'Introduction to Computer Engineering', 1, @CompEngDeptID_Course), ('2510111', 'General English for Engineering', 3, @GeneralDeptID_Course), ('GENED-PE1', 'Physical Education 1', 1, @GeneralDeptID_Course), ('GENED-IS1', 'Islamic Studies 1', 2, @GeneralDeptID_Course);
    -- Term 2
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1914107', 'General Mathematics 2', 3, @BasicSciDeptID_Course), ('2010125', 'Physics 2', 3, @BasicSciDeptID_Course), ('1734102', 'Advanced Programming & Lab', 4, @CompEngDeptID_Course), ('1730217', 'Discrete Structures', 3, @CompEngDeptID_Course), ('1914251', 'Differential Equations', 3, @BasicSciDeptID_Course), ('2010126', 'Physics Lab (Electricity)', 1, @BasicSciDeptID_Course), ('GENED-IS2', 'Islamic Studies 2', 2, @GeneralDeptID_Course);
    -- Term 3
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1912291', 'Engineering Probability and Statistics', 3, @BasicSciDeptID_Course), ('1914252', 'Engineering Mathematics', 3, @BasicSciDeptID_Course), ('1732207', 'Electrical & Electronic Circuits', 3, @ElecEngDeptID_Course), ('1734212', 'Data Structures', 3, @CompEngDeptID_Course), ('1732203', 'Digital Design 1', 3, @CompEngDeptID_Course), ('1732204', 'Digital Design 1 Lab', 1, @CompEngDeptID_Course), ('2610252', 'Persian Language', 3, @GeneralDeptID_Course);
    -- Term 4
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1732208', 'Computer Architecture & Organization', 3, @CompEngDeptID_Course), ('1740320', 'Computer Networks', 3, @CompEngDeptID_Course), ('1734425', 'Design of Algorithms', 3, @CompEngDeptID_Course), ('1734303', 'Database Systems 1', 3, @CompEngDeptID_Course), ('1740404', 'Computer Networks Lab', 1, @CompEngDeptID_Course), ('2510318', 'English for Computer Majors', 2, @GeneralDeptID_Course), ('GENED-PE2', 'Physical Education 2', 1, @GeneralDeptID_Course), ('GENED-IS3', 'Islamic Studies 3', 2, @GeneralDeptID_Course);
    -- Term 5
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1732312', 'Microprocessors', 3, @CompEngDeptID_Course), ('1734320', 'Operating Systems', 3, @CompEngDeptID_Course), ('1718210', 'Signals & Systems', 3, @ElecEngDeptID_Course), ('1734420', 'Artificial Intelligence', 3, @CompEngDeptID_Course), ('1734325', 'Theory of Languages and Automata', 3, @CompEngDeptID_Course), ('1734304', 'Operating Systems Lab', 1, @CompEngDeptID_Course), ('GENED-IS4', 'Islamic Studies 4', 2, @GeneralDeptID_Course);
    -- Term 6 (Software Track)
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1732401', 'Microprocessor Lab', 1, @CompEngDeptID_Course), ('1740312', 'Technical & Scientific Presentation', 2, @GeneralDeptID_Course), ('1736310', 'Computer Networks 2', 3, @CompEngDeptID_Course), ('173xxxx1', 'Cloud Computing', 3, @CompEngDeptID_Course), ('999xxxx1', 'Elective Course 1 (Term 6)', 3, @CompEngDeptID_Course), ('GENED-IS5', 'Islamic Studies 5', 2, @GeneralDeptID_Course);
    -- Term 7 (Software Track)
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1734312', 'Software Engineering 1', 3, @CompEngDeptID_Course), ('1734307', 'Software Engineering 1 Lab', 1, @CompEngDeptID_Course), ('1734333', 'Compiler Design', 3, @CompEngDeptID_Course), ('1734452', 'Database Lab', 1, @CompEngDeptID_Course), ('1740350', 'Bachelor''s Project', 3, @CompEngDeptID_Course), ('999xxxx2', 'Elective Course 2 (Term 7)', 3, @CompEngDeptID_Course), ('GENED-IS6', 'Islamic Studies 6', 2, @GeneralDeptID_Course);
    -- Term 8 (Software Track)
    INSERT INTO Education.Courses (CourseCode, CourseName, Credits, DepartmentID) VALUES ('1734449', 'Software Engineering 2', 3, @CompEngDeptID_Course), ('1730403', 'Fundamentals of Data Mining', 3, @CompEngDeptID_Course), ('1734308', 'Database Systems 2', 3, @CompEngDeptID_Course), ('173xxxx2', 'Graph Mining', 3, @CompEngDeptID_Course), ('999xxxx3', 'Elective Course 3 (Term 8)', 2, @CompEngDeptID_Course), ('GENED-IS7', 'Islamic Studies 7', 2, @GeneralDeptID_Course);

    PRINT 'All courses inserted successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error inserting courses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    DECLARE @AvailableCopyStatusID INT = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Available');
    DECLARE @BorrowedCopyStatusID INT = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Borrowed'); -- This might be wrong, should be BookCopyStatuses

 
    SET @AvailableCopyStatusID = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Available');
    SET @BorrowedCopyStatusID = (SELECT CopyStatusID FROM Library.BookCopyStatuses WHERE StatusName = 'Borrowed');


    -- Get Book IDs 
    DECLARE @RefactoringBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321125217');
    DECLARE @LordOfTheRingsBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321765723');
    DECLARE @NietzscheBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-6002291334');
    DECLARE @KelidarBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-9643052849');
    DECLARE @HeadFirstJavaBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0596007126');
    DECLARE @CleanCodeBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0132350884');

    INSERT INTO Library.BookCopies (BookID, AcquisitionDate, CopyStatusID, LocationInLibrary, PurchasePrice) VALUES
    (@RefactoringBookID, '2020-01-10', @AvailableCopyStatusID, 'CS Shelf 1-A', 50.00),
    (@RefactoringBookID, '2020-01-10', @AvailableCopyStatusID, 'CS Shelf 1-A', 50.00), -- Another copy
    (@LordOfTheRingsBookID, '2019-05-20', @AvailableCopyStatusID, 'Fiction 2-C', 35.00),
    (@LordOfTheRingsBookID, '2019-05-20', @AvailableCopyStatusID, 'Fiction 2-C', 35.00), -- Another copy
    (@NietzscheBookID, '2021-03-01', @AvailableCopyStatusID, 'Phil 3-B', 25.00),
    (@KelidarBookID, '2021-03-01', @AvailableCopyStatusID, 'IranLit 1-D', 40.00),
    (@HeadFirstJavaBookID, '2022-02-15', @AvailableCopyStatusID, 'CS Shelf 1-B', 45.00),
    (@CleanCodeBookID, '2022-02-15', @AvailableCopyStatusID, 'SE Shelf 2-A', 55.00),
    (@CleanCodeBookID, '2022-02-15', @AvailableCopyStatusID, 'SE Shelf 2-A', 55.00);-- Another copy
    PRINT 'Book Copies seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Book Copies: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    DECLARE @MartinFowlerID INT = (SELECT AuthorID FROM Library.Authors WHERE LastName = 'Fowler');
    DECLARE @IrvinYalomID INT = (SELECT AuthorID FROM Library.Authors WHERE LastName = 'Yalom');
    DECLARE @MahmoudDowlatabadiID INT = (SELECT AuthorID FROM Library.Authors WHERE LastName = 'Dowlatabadi');
    DECLARE @RobertCMartinID INT = (SELECT AuthorID FROM Library.Authors WHERE LastName = 'Martin');


	DECLARE @RefactoringBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321125217');
    DECLARE @LordOfTheRingsBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321765723');
    DECLARE @NietzscheBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-6002291334');
    DECLARE @KelidarBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-9643052849');
    DECLARE @HeadFirstJavaBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0596007126');
    DECLARE @CleanCodeBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0132350884');


    INSERT INTO Library.BookAuthors (BookID, AuthorID, AuthorRole) VALUES
    (@RefactoringBookID, @MartinFowlerID, 'Primary Author'),
    (@NietzscheBookID, @IrvinYalomID, 'Primary Author'),
    (@KelidarBookID, @MahmoudDowlatabadiID, 'Primary Author'),
    (@CleanCodeBookID, @RobertCMartinID, 'Primary Author');
    PRINT 'Book Authors seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Book Authors: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO


BEGIN TRY
    DECLARE @CompSciCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Computer Science');
    DECLARE @SoftwareEngCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Software Engineering');
    DECLARE @PsychologyCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Psychology');
    DECLARE @PhilosophyCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Philosophy');
    DECLARE @IranianLitCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Iranian Literature');
    DECLARE @FictionCatID INT = (SELECT CategoryID FROM Library.Categories WHERE CategoryName = 'Fiction');

	
	DECLARE @RefactoringBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321125217');
    DECLARE @LordOfTheRingsBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0321765723');
    DECLARE @NietzscheBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-6002291334');
    DECLARE @KelidarBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-9643052849');
    DECLARE @HeadFirstJavaBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0596007126');
    DECLARE @CleanCodeBookID INT = (SELECT BookID FROM Library.Books WHERE ISBN = '978-0132350884');
    
    INSERT INTO Library.BookCategories (BookID, CategoryID) VALUES
    (@RefactoringBookID, @CompSciCatID), (@RefactoringBookID, @SoftwareEngCatID),
    (@LordOfTheRingsBookID, @FictionCatID),
    (@NietzscheBookID, @PsychologyCatID), (@NietzscheBookID, @PhilosophyCatID),
    (@KelidarBookID, @IranianLitCatID), (@KelidarBookID, @FictionCatID),
    (@HeadFirstJavaBookID, @CompSciCatID),
    (@CleanCodeBookID, @CompSciCatID), (@CleanCodeBookID, @SoftwareEngCatID);
    PRINT 'Book Categories seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Book Categories: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    -- Get Course IDs 
    DECLARE @Math1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914101');
    DECLARE @Math2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914107');
    DECLARE @Physics1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010115');
    DECLARE @Physics2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010125');
    DECLARE @ProgFund_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730115');
    DECLARE @AdvProg_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734102');
    DECLARE @Discrete_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730217');
    DECLARE @DiffEq_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914251');
    DECLARE @PhysicsLab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010126');
    DECLARE @Stats_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1912291');
    DECLARE @EngMath_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914252');
    DECLARE @Circuits_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732207');
    DECLARE @DataStruct_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734212');
    DECLARE @DigitalDesign1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732203');
    DECLARE @DigitalDesign1Lab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732204');
    DECLARE @Arch_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732208');
    DECLARE @Networks_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740320');
    DECLARE @Algorithms_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734425');
    DECLARE @DB1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734303');
    DECLARE @NetworksLab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740404');
    DECLARE @EngLang_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2510111');
    DECLARE @SpecLang_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2510318');
    DECLARE @PE1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-PE1');
    DECLARE @PE2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-PE2');
    DECLARE @Microproc_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732312');
    DECLARE @OS_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734320');
    DECLARE @Signals_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1718210');
    DECLARE @AI_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734420');
    DECLARE @Automata_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734325');
    DECLARE @OSLab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734304');
    DECLARE @MicroprocLab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732401');
    DECLARE @Presentation_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740312');
    DECLARE @Networks2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1736310');
    DECLARE @Cloud_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '173xxxx1');
    DECLARE @SoftEng1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734312');
    DECLARE @SoftEng1Lab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734307');
    DECLARE @Compiler_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734333');
    DECLARE @DBLab_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734452');
    DECLARE @Project_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740350');
    DECLARE @SoftEng2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734449');
    DECLARE @DataMining_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730403');
    DECLARE @DB2_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734308');
    DECLARE @GraphMining_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '173xxxx2');


    -- Insert Prerequisites (and co-requisites as prerequisites)
    INSERT INTO Education.Prerequisites(CourseID, PrerequisiteCourseID) VALUES
    -- Term 2
    (@Math2_ID, @Math1_ID), (@Physics2_ID, @Physics1_ID), (@AdvProg_ID, @ProgFund_ID),
    (@DiffEq_ID, @Math1_ID), (@DiffEq_ID, @Math2_ID), (@PhysicsLab_ID, @Physics2_ID),
	(@Discrete_ID,@ProgFund_ID),
    -- Term 3
    (@Stats_ID, @Math2_ID), (@EngMath_ID, @Math2_ID), (@Circuits_ID, @Physics2_ID),
    (@Circuits_ID, @DiffEq_ID), (@DataStruct_ID, @AdvProg_ID), (@DataStruct_ID, @Discrete_ID),
    (@DigitalDesign1Lab_ID, @DigitalDesign1_ID),
    -- Term 4
    (@Arch_ID, @DigitalDesign1_ID), (@Networks_ID, @Stats_ID), (@Networks_ID, @DataStruct_ID),
    (@Algorithms_ID, @DataStruct_ID), (@DB1_ID, @DataStruct_ID), (@NetworksLab_ID, @Networks_ID),
    (@SpecLang_ID, @EngLang_ID), (@PE2_ID, @PE1_ID),
    -- Term 5
    (@Microproc_ID, @Arch_ID), (@OS_ID, @Arch_ID), (@Signals_ID, @EngMath_ID),
    (@AI_ID, @DataStruct_ID), (@AI_ID, @Algorithms_ID), (@Automata_ID, @DataStruct_ID),
    (@OSLab_ID, @OS_ID),
    -- Term 6 (Software)
    (@MicroprocLab_ID, @DigitalDesign1_ID), (@MicroprocLab_ID, @Microproc_ID), (@Presentation_ID, @SpecLang_ID),
    (@Networks2_ID, @Networks_ID), (@Cloud_ID, @Networks_ID), (@Cloud_ID, @OS_ID),
    -- Term 7 (Software)
    (@SoftEng1_ID, @DB1_ID), (@SoftEng1Lab_ID, @SoftEng1_ID), (@Compiler_ID, @Automata_ID),
    (@DBLab_ID, @DB1_ID),
    -- Term 8 (Software)
    (@SoftEng2_ID, @DB1_ID), (@SoftEng2_ID, @SoftEng1_ID), (@DataMining_ID, @DB1_ID),
    (@DB2_ID, @DB1_ID), (@GraphMining_ID, @Algorithms_ID), (@GraphMining_ID, @DB1_ID),
    (@GraphMining_ID, @Stats_ID);

    PRINT 'All prerequisites inserted successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error inserting prerequisites: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO


-- Insert Curriculum Data (for Computer Engineering - Software Major)
PRINT 'Inserting curriculum data...';
BEGIN TRY
    DECLARE @MajorID_Curriculum INT;
    SELECT @MajorID_Curriculum = MajorID FROM Education.Majors WHERE MajorName = 'Computer Engineering'; -- Major name updated

   
    IF @MajorID_Curriculum IS NULL
    BEGIN
        RAISERROR('The major "Computer Engineering" was not found. Halting curriculum insertion.', 16, 1);
        RETURN;
    END

	-- 1-3: Comp Eng / Elec Eng core courses (higher priority)
    -- 4-6: Basic Sciences core courses (medium priority)
    -- 7-9: General Education core courses (lower priority)

	-- Term 1
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914101'), 1, 1, 4), -- Math 1 (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010115'), 1, 1, 5), -- Physics 1 (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730115'), 1, 1, 1), -- Prog Fund (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730101'), 1, 1, 2), -- Comp Workshop (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730103'), 1, 1, 3), -- Intro Comp Eng (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2510111'), 1, 1, 7), -- Gen English (General)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-PE1'), 1, 1, 8), -- PE 1 (General)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS1'), 1, 1, 9); -- IS 1 (General)

	 -- Term 2
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914107'), 2, 1, 4), -- Math 2 (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010125'), 2, 1, 5), -- Physics 2 (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734102'), 2, 1, 1), -- Adv Prog (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730217'), 2, 1, 2), -- Discrete (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914251'), 2, 1, 6), -- Diff Eq (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010126'), 2, 1, 6), -- Physics Lab (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS2'), 2, 1, 9); -- IS 2 (General)


	-- Term 3
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1912291'), 3, 1, 4), -- Stats (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914252'), 3, 1, 5), -- Eng Math (Basic Sci)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732207'), 3, 1, 1), -- Circuits (Elec Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734212'), 3, 1, 1), -- Data Struct (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732203'), 3, 1, 2), -- Digital Design 1 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732204'), 3, 1, 2), -- Digital Design 1 Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2610252'), 3, 1, 7); -- Persian (General)

	-- Term 4
	INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732208'), 4, 1, 2), -- Arch (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740320'), 4, 1, 2), -- Networks (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734425'), 4, 1, 1), -- Algorithms (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734303'), 4, 1, 2), -- DB1 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740404'), 4, 1, 3), -- Networks Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2510318'), 4, 1, 7), -- Eng English 
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-PE2'), 4, 1, 8), -- PE 2 (General)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS3'), 4, 1, 9); -- IS 3 (General)

	 -- Term 5
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732312'), 5, 1, 1), -- Microproc (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734320'), 5, 1, 2), -- OS (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1718210'), 5, 1, 3), -- Signals (Elec Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734420'), 5, 1, 1), -- AI (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734325'), 5, 1, 2), -- Automata (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734304'), 5, 1, 2), -- OS Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS4'), 5, 1, 9); -- IS 4 (General)

	-- Term 6 (Software Track)
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732401'), 6, 1, 1), -- Microproc Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740312'), 6, 1, 7), -- Presentation (General)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1736310'), 6, 1, 2), -- Networks 2 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '173xxxx1'), 6, 0, 10), -- Cloud Computing (Elective)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '999xxxx1'), 6, 0, 10), -- Elective 1 (General Elective)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS5'), 6, 1, 9); -- IS 5 (General)

	-- Term 7 (Software Track)
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734312'), 7, 1, 1), -- Soft Eng 1 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734307'), 7, 1, 1), -- Soft Eng 1 Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734333'), 7, 1, 2), -- Compiler (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734452'), 7, 1, 1), -- DB Lab (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740350'), 7, 1, 3), -- Project (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '999xxxx2'), 7, 0, 10), -- Elective 2 (General Elective)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS6'), 7, 1, 9); -- IS 6 (General)

	  -- Term 8 (Software Track)
    INSERT INTO Education.Curriculum(MajorID, CourseID, SuggestedTerm, IsCoreRequirement, Priority) VALUES
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734449'), 8, 1, 1), -- Soft Eng 2 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730403'), 8, 1, 2), -- Data Mining (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734308'), 8, 1, 1), -- DB 2 (Comp Eng)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '173xxxx2'), 8, 0, 10), -- Graph Mining (Elective)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = '999xxxx3'), 8, 0, 10), -- Elective 3 (General Elective)
    (@MajorID_Curriculum, (SELECT CourseID FROM Education.Courses WHERE CourseCode = 'GENED-IS7'), 8, 1, 9); -- IS 7 (General)

    PRINT 'All curriculum data seeded successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error inserting curriculum data: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO 


BEGIN TRY
    -- Get Semester IDs
    DECLARE @Fall2023_ID INT = (SELECT SemesterID FROM Education.Semesters WHERE SemesterID = 20231);
    DECLARE @Spring2024_ID INT = (SELECT SemesterID FROM Education.Semesters WHERE SemesterID = 20241);
    DECLARE @Summer2024_ID INT = (SELECT SemesterID FROM Education.Semesters WHERE SemesterID = 20242);
    DECLARE @Fall2024_ID INT = (SELECT SemesterID FROM Education.Semesters WHERE SemesterID = 20251);

    -- Get Professor IDs 
    DECLARE @ProfNaderID INT = (SELECT ProfessorID FROM Education.Professors WHERE Email = 'n.karimi@university.com');
    DECLARE @ProfShirinID INT = (SELECT ProfessorID FROM Education.Professors WHERE Email = 's.baghool@university.com');
    DECLARE @ProfSajadID INT = (SELECT ProfessorID FROM Education.Professors WHERE Email = 's.mari@university.com');

    -- Get Room IDs
    DECLARE @RoomE101_ID INT = (SELECT RoomID FROM Education.Rooms WHERE RoomNumber = 'E-101');
    DECLARE @RoomE102_ID INT = (SELECT RoomID FROM Education.Rooms WHERE RoomNumber = 'E-102');
    DECLARE @RoomE203_ID INT = (SELECT RoomID FROM Education.Rooms WHERE RoomNumber = 'E-203');
    DECLARE @RoomS300_ID INT = (SELECT RoomID FROM Education.Rooms WHERE RoomNumber = 'S-300');

    -- Get Course IDs 
    DECLARE @Math1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1914101');
    DECLARE @Physics1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '2010115');
    DECLARE @ProgFund_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730115');
    DECLARE @AdvProg_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734102');
    DECLARE @Discrete_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1730217');
    DECLARE @DB1_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734303');
    DECLARE @Arch_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1732208');
    DECLARE @OS_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1734320');
    DECLARE @Networks_ID INT = (SELECT CourseID FROM Education.Courses WHERE CourseCode = '1740320');


    -- Term 1 courses offered in Fall 2023
    INSERT INTO Education.OfferedCourses (CourseID, ProfessorID, SemesterID, Capacity, RoomID, ScheduleInfo) VALUES
    (@Math1_ID, @ProfSajadID, @Fall2023_ID, 100, @RoomS300_ID, 'Sun/Tue 08:00-10:00'),
    (@Physics1_ID, @ProfSajadID, @Fall2023_ID, 100, @RoomS300_ID, 'Mon/Wed 08:00-10:00'),
    (@ProgFund_ID, @ProfNaderID, @Fall2023_ID, 50, @RoomE101_ID, 'Sat/Mon 10:00-12:00');

    -- Term 2 courses offered in Spring 2024
    INSERT INTO Education.OfferedCourses (CourseID, ProfessorID, SemesterID, Capacity, RoomID, ScheduleInfo) VALUES
    (@AdvProg_ID, @ProfNaderID, @Spring2024_ID, 40, @RoomE102_ID, 'Sun/Tue 14:00-16:00'),
    (@Discrete_ID, @ProfShirinID, @Spring2024_ID, 40, @RoomE101_ID, 'Mon/Wed 14:00-16:00'),
	(@Math1_ID, @ProfSajadID, @Spring2024_ID, 60, @RoomS300_ID, 'Sun/Tue 12:00-14:00'),
    (@Physics1_ID, @ProfSajadID, @Spring2024_ID, 60, @RoomS300_ID, 'Mon/Wed 12:00-14:00'), 
    (@ProgFund_ID, @ProfNaderID, @Spring2024_ID, 30, @RoomE101_ID, 'Sat/Mon 12:00-14:00'); 

    -- Higher level courses offered in Fall 2024 (for future enrollment/suggestion tests)
    INSERT INTO Education.OfferedCourses (CourseID, ProfessorID, SemesterID, Capacity, RoomID, ScheduleInfo) VALUES
    (@DB1_ID, @ProfShirinID, @Fall2024_ID, 30, @RoomE203_ID, 'Sat/Mon 10:00-12:00'),
    (@Arch_ID, @ProfNaderID, @Fall2024_ID, 30, @RoomE203_ID, 'Sun/Tue 10:00-12:00'),
    (@OS_ID, @ProfShirinID, @Fall2024_ID, 30, @RoomE203_ID, 'Mon/Wed 10:00-12:00'),
    (@Networks_ID, @ProfNaderID, @Fall2024_ID, 30, @RoomE101_ID, 'Tue/Thu 14:00-16:00');

    PRINT 'Offered Courses seeded successfully for multiple semesters.';
END TRY
BEGIN CATCH
    PRINT 'Error seeding Offered Courses: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

