-- 015_decorator.sql
-- Decorator contact, notes, planning fields, and inspiration items

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Decorator contact columns on WeddingSites
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_name')
    ALTER TABLE dbo.WeddingSites ADD decorator_name       NVARCHAR(150) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_company')
    ALTER TABLE dbo.WeddingSites ADD decorator_company    NVARCHAR(150) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_email')
    ALTER TABLE dbo.WeddingSites ADD decorator_email      NVARCHAR(320) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_phone')
    ALTER TABLE dbo.WeddingSites ADD decorator_phone      NVARCHAR(30)  NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_website')
    ALTER TABLE dbo.WeddingSites ADD decorator_website    NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_notes')
    ALTER TABLE dbo.WeddingSites ADD decorator_notes      NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_include_notes')
    ALTER TABLE dbo.WeddingSites ADD decorator_include_notes BIT NOT NULL CONSTRAINT DF_WeddingSites_DecoratorIncludeNotes DEFAULT (1);
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_color_palette')
    ALTER TABLE dbo.WeddingSites ADD decorator_color_palette  NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_floral_prefs')
    ALTER TABLE dbo.WeddingSites ADD decorator_floral_prefs   NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_ceremony_layout')
    ALTER TABLE dbo.WeddingSites ADD decorator_ceremony_layout  NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_reception_layout')
    ALTER TABLE dbo.WeddingSites ADD decorator_reception_layout NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='decorator_special_instructions')
    ALTER TABLE dbo.WeddingSites ADD decorator_special_instructions NVARCHAR(MAX) NULL;

-- Design inspiration items
IF OBJECT_ID('dbo.InspirationItems', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.InspirationItems (
        item_id         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id         BIGINT NOT NULL,
        title           NVARCHAR(300) NOT NULL,
        category        NVARCHAR(100) NOT NULL,
        inspiration_url NVARCHAR(1000) NULL,
        description     NVARCHAR(MAX) NULL,
        priority        NVARCHAR(30) NOT NULL CONSTRAINT DF_InspirationItems_Priority DEFAULT ('Preferred'),
        sort_order      INT NOT NULL CONSTRAINT DF_InspirationItems_Sort DEFAULT (0),
        created_at      DATETIME2(0) NOT NULL CONSTRAINT DF_InspirationItems_Created DEFAULT SYSUTCDATETIME(),
        updated_at      DATETIME2(0) NOT NULL CONSTRAINT DF_InspirationItems_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_InspirationItems_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
        CONSTRAINT CK_InspirationItems_Priority CHECK (priority IN ('Must Have','Preferred','Nice to Have'))
    );
    CREATE INDEX IX_InspirationItems_UserId ON dbo.InspirationItems(user_id, sort_order);
END;

COMMIT TRANSACTION;
