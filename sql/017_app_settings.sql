IF OBJECT_ID('dbo.AppSettings','U') IS NULL
CREATE TABLE dbo.AppSettings (
    setting_key   NVARCHAR(100)  NOT NULL PRIMARY KEY,
    setting_value NVARCHAR(MAX)  NULL,
    updated_at    DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME()
);

IF NOT EXISTS (SELECT 1 FROM dbo.AppSettings WHERE setting_key = 'premiumTemplates')
    INSERT INTO dbo.AppSettings (setting_key, setting_value) VALUES ('premiumTemplates', '');
