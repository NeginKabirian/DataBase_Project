IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'Database_project')
BEGIN
    CREATE DATABASE [Database_project]; 
    PRINT 'Database [Database_project] created successfully.';
END
ELSE
BEGIN
    PRINT 'Database [Database_project] already exists.';
END
GO