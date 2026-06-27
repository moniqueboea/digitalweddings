-- Add is_admin column to Users table
ALTER TABLE dbo.Users ADD is_admin BIT NOT NULL DEFAULT 0;

-- Set moniqueboea@gmail.com as admin
UPDATE dbo.Users SET is_admin = 1 WHERE email = 'moniqueboea@gmail.com';

-- Add complimentary column to Vendors table
ALTER TABLE dbo.Vendors ADD complimentary BIT NOT NULL DEFAULT 0;
