SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.PasswordResetTokens (
    token_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at DATETIME2(0) NOT NULL,
    used_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_PasswordResetTokens_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_PasswordResetTokens_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT UQ_PasswordResetTokens_Hash UNIQUE (token_hash)
);

CREATE INDEX IX_PasswordResetTokens_UserId
    ON dbo.PasswordResetTokens(user_id);

COMMIT TRANSACTION;
