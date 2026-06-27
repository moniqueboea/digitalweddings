IF OBJECT_ID('dbo.UserPlanningSettings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserPlanningSettings (
        user_id BIGINT NOT NULL PRIMARY KEY,
        total_budget DECIMAL(12,2) NOT NULL CONSTRAINT DF_UserPlanningSettings_TotalBudget DEFAULT (0),
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_UserPlanningSettings_CreatedAt DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_UserPlanningSettings_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_UserPlanningSettings_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
    );
END;

IF OBJECT_ID('dbo.SaveTheDates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SaveTheDates (
        save_the_date_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id BIGINT NOT NULL,
        wedding_site_id BIGINT NOT NULL,
        recipient_email VARCHAR(320) NOT NULL,
        recipient_name NVARCHAR(200) NULL,
        sender_name NVARCHAR(200) NOT NULL,
        token_hash VARCHAR(64) NOT NULL,
        rsvp_status VARCHAR(20) NOT NULL CONSTRAINT DF_SaveTheDates_Rsvp DEFAULT ('pending'),
        sent_at DATETIME2(0) NULL,
        responded_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT DF_SaveTheDates_CreatedAt DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_SaveTheDates_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_SaveTheDates_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
        CONSTRAINT FK_SaveTheDates_WeddingSites FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites(wedding_site_id),
        CONSTRAINT UQ_SaveTheDates_Token UNIQUE (token_hash),
        CONSTRAINT CK_SaveTheDates_Rsvp CHECK (rsvp_status IN ('pending', 'attending', 'declined'))
    );

    CREATE INDEX IX_SaveTheDates_UserId ON dbo.SaveTheDates(user_id);
    CREATE INDEX IX_SaveTheDates_WeddingSiteId ON dbo.SaveTheDates(wedding_site_id);
END;
