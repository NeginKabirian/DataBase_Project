IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Education')
BEGIN
    EXEC('CREATE SCHEMA Education');
    PRINT 'Schema Education created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema Education already exists.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Library')
BEGIN
    EXEC('CREATE SCHEMA Library');
    PRINT 'Schema Library created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema Library already exists.';
END
GO