DELETE FROM Education.Students;

BULK INSERT Education.Students
FROM 'D:\DB_Project\DataBase_Project\Students_Data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,               
    FIELDTERMINATOR = ',',     
    ROWTERMINATOR = '\n',      
    CODEPAGE = '65001',         
    TABLOCK
);

select *
from Education.Students
DELETE FROM Library.Books;
BULK INSERT Library.Books
FROM 'C:\Users\ZBook Fury\Desktop\Books_Data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,               
    FIELDTERMINATOR = ',',     
    ROWTERMINATOR = '\n',      
    CODEPAGE = '65001',         
    TABLOCK
);
select *
from Library.Books