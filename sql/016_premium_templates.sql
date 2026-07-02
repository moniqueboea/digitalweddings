-- 016_premium_templates.sql
-- Tracks which premium templates have been unlocked per wedding site

SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID('dbo.PremiumTemplateUnlocks','U') IS NULL
BEGIN
    CREATE TABLE dbo.PremiumTemplateUnlocks (
        unlock_id               BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id                 BIGINT NOT NULL,
        wedding_site_id         BIGINT NOT NULL,
        template_name           NVARCHAR(100) NOT NULL,
        stripe_session_id       NVARCHAR(500) NULL,
        stripe_payment_intent   NVARCHAR(500) NULL,
        amount_paid             DECIMAL(10,2) NOT NULL DEFAULT(14.99),
        unlocked_at             DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PremiumUnlocks_Users        FOREIGN KEY (user_id)         REFERENCES dbo.Users(user_id)        ON DELETE CASCADE,
        CONSTRAINT FK_PremiumUnlocks_Sites        FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites(wedding_site_id) ON DELETE NO ACTION,
        CONSTRAINT UQ_PremiumUnlocks_SiteTpl      UNIQUE (wedding_site_id, template_name)
    );
    CREATE INDEX IX_PremiumUnlocks_UserId ON dbo.PremiumTemplateUnlocks(user_id);
END;

COMMIT TRANSACTION;
