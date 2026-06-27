-- Ensure SaveTheDates table exists (matches 007 migration)
IF OBJECT_ID('dbo.SaveTheDates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SaveTheDates (
        save_the_date_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id          BIGINT NOT NULL,
        wedding_site_id  BIGINT NOT NULL,
        recipient_name   NVARCHAR(200) NOT NULL,
        recipient_email  VARCHAR(320)  NOT NULL,
        rsvp_status      VARCHAR(20)   NOT NULL CONSTRAINT DF_SaveTheDates_Rsvp    DEFAULT ('pending'),
        sent_at          DATETIME2(0)  NULL,
        created_at       DATETIME2(0)  NOT NULL CONSTRAINT DF_SaveTheDates_Created DEFAULT SYSUTCDATETIME(),
        updated_at       DATETIME2(0)  NOT NULL CONSTRAINT DF_SaveTheDates_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_SaveTheDates_Users        FOREIGN KEY (user_id)         REFERENCES dbo.Users(user_id)        ON DELETE CASCADE,
        CONSTRAINT FK_SaveTheDates_WeddingSites FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites(wedding_site_id),
        CONSTRAINT CK_SaveTheDates_Rsvp        CHECK (rsvp_status IN ('pending', 'attending', 'declined'))
    );
    CREATE INDEX IX_SaveTheDates_UserId ON dbo.SaveTheDates(user_id);
END;

-- Add sent_at if missing from older installs
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='SaveTheDates' AND COLUMN_NAME='sent_at')
    ALTER TABLE dbo.SaveTheDates ADD sent_at DATETIME2(0) NULL;
