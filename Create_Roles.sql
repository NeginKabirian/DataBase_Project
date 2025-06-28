USE Database_project;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'EducationAdminRole' AND type = 'R') CREATE ROLE EducationAdminRole; 
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'LibrarianRole' AND type = 'R') CREATE ROLE LibrarianRole;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'StudentRole' AND type = 'R') CREATE ROLE StudentRole;
GO