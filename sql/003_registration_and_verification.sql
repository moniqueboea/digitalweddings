/*
    Run this migration only if 001_initial_schema.sql was already applied
    before registration and email verification fields were added.
*/

SET XACT_ABORT ON;
BEGIN TRANSACTION;

ALTER TABLE dbo.Users ADD
    username VARCHAR(30) COLLATE Latin1_General_100_CI_AS NULL,
    first_name NVARCHAR(100) NULL,
    last_name NVARCHAR(100) NULL,
    email_verified_at DATETIME2(0) NULL;

UPDATE dbo.Users
SET username = CONCAT('user', user_id),
    first_name = 'Existing',
    last_name = 'User',
    email_verified_at = CASE WHEN is_active = 1 THEN SYSUTCDATETIME() ELSE NULL END
WHERE username IS NULL;

ALTER TABLE dbo.Users ALTER COLUMN username VARCHAR(30) COLLATE Latin1_General_100_CI_AS NOT NULL;
ALTER TABLE dbo.Users ALTER COLUMN email VARCHAR(320) COLLATE Latin1_General_100_CI_AS NOT NULL;
ALTER TABLE dbo.Users ALTER COLUMN first_name NVARCHAR(100) NOT NULL;
ALTER TABLE dbo.Users ALTER COLUMN last_name NVARCHAR(100) NOT NULL;

ALTER TABLE dbo.Users ADD CONSTRAINT UQ_Users_Username UNIQUE (username);
ALTER TABLE dbo.Users DROP CONSTRAINT DF_Users_IsActive;
ALTER TABLE dbo.Users ADD CONSTRAINT DF_Users_IsActive DEFAULT (0) FOR is_active;

CREATE TABLE dbo.EmailVerificationTokens (
    token_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at DATETIME2(0) NOT NULL,
    used_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_EmailVerificationTokens_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_EmailVerificationTokens_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT UQ_EmailVerificationTokens_Hash UNIQUE (token_hash)
);

CREATE INDEX IX_EmailVerificationTokens_UserId ON dbo.EmailVerificationTokens(user_id);

COMMIT TRANSACTION;
