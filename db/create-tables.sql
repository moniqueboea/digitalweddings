-- ============================================================
-- digitalweddings.love  - Full Schema
-- SQL Server 2016+  (run once; safe to re-run via IF NOT EXISTS)
-- ============================================================

-- ── Users ───────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Users' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.Users (
    user_id             BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    username            VARCHAR(100)    NOT NULL UNIQUE,
    first_name          NVARCHAR(100)   NOT NULL,
    last_name           NVARCHAR(100)   NOT NULL,
    email               VARCHAR(255)    NOT NULL UNIQUE,
    password_hash       VARCHAR(512)    NOT NULL,
    password_salt       VARCHAR(255)    NOT NULL,
    password_iterations INT             NOT NULL DEFAULT 10000,
    password_algorithm  VARCHAR(50)     NOT NULL DEFAULT 'PBKDF2WithHmacSHA256',
    role                VARCHAR(50)     NOT NULL DEFAULT 'user',
    is_active           BIT             NOT NULL DEFAULT 0,
    is_admin            BIT             NOT NULL DEFAULT 0,
    email_verified_at   DATETIME2       NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Email Verification Tokens ────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='EmailVerificationTokens' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.EmailVerificationTokens (
    token_id    BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    token_hash  VARCHAR(512)    NOT NULL,
    expires_at  DATETIME2       NOT NULL,
    used_at     DATETIME2       NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Password Reset Tokens ────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='PasswordResetTokens' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.PasswordResetTokens (
    token_id    BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    token_hash  VARCHAR(512)    NOT NULL,
    expires_at  DATETIME2       NOT NULL,
    used_at     DATETIME2       NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Vendors ──────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Vendors' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.Vendors (
    vendor_id       BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    business_name   NVARCHAR(255)   NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    category        NVARCHAR(100)   NULL,
    description     NVARCHAR(MAX)   NULL,
    location        NVARCHAR(255)   NULL,
    phone           VARCHAR(50)     NULL,
    website_url     VARCHAR(500)    NULL,
    photo_url       VARCHAR(500)    NULL,
    complimentary   BIT             NOT NULL DEFAULT 0,
    status          VARCHAR(50)     NOT NULL DEFAULT 'pending',  -- pending, active, inactive
    created_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Vendor Analytics ─────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='VendorAnalytics' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.VendorAnalytics (
    analytic_id BIGINT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
    vendor_id   BIGINT      NOT NULL REFERENCES dbo.Vendors(vendor_id) ON DELETE CASCADE,
    event_type  VARCHAR(50) NOT NULL,  -- view, website_click, email_click, phone_click
    event_date  DATE        NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS date),
    created_at  DATETIME2   NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Vendor Messages ──────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='VendorMessages' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.VendorMessages (
    message_id      BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    vendor_id       BIGINT          NOT NULL REFERENCES dbo.Vendors(vendor_id) ON DELETE CASCADE,
    sender_name     NVARCHAR(255)   NOT NULL,
    sender_email    VARCHAR(255)    NOT NULL,
    message         NVARCHAR(MAX)   NOT NULL,
    is_read         BIT             NOT NULL DEFAULT 0,
    created_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Vendor Reviews ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='VendorReviews' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.VendorReviews (
    review_id   BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    vendor_id   BIGINT          NOT NULL REFERENCES dbo.Vendors(vendor_id) ON DELETE CASCADE,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id),
    rating      TINYINT         NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text NVARCHAR(MAX)   NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Wedding Sites ────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='WeddingSites' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.WeddingSites (
    site_id                  BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id                  BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    template                 VARCHAR(100)    NOT NULL DEFAULT 'classic',
    couple_name_1            NVARCHAR(150)   NULL,
    couple_name_2            NVARCHAR(150)   NULL,
    wedding_date             DATE            NULL,
    venue_name               NVARCHAR(255)   NULL,
    venue_address            NVARCHAR(500)   NULL,
    reception_venue_name     NVARCHAR(255)   NULL,
    reception_venue_address  NVARCHAR(500)   NULL,
    story                    NVARCHAR(MAX)   NULL,
    scripture                NVARCHAR(MAX)   NULL,
    dress_code               NVARCHAR(500)   NULL,
    travel_info              NVARCHAR(MAX)   NULL,
    travel_links_json        NVARCHAR(MAX)   NULL,
    things_to_do             NVARCHAR(MAX)   NULL,
    things_links_json        NVARCHAR(MAX)   NULL,
    hero_image_url           NVARCHAR(500)   NULL,
    couple_photo_url         NVARCHAR(500)   NULL,
    gallery_images_json      NVARCHAR(MAX)   NULL,
    faq_json                 NVARCHAR(MAX)   NULL,
    slug                     VARCHAR(200)    NULL UNIQUE,
    published                BIT             NOT NULL DEFAULT 0,
    created_at               DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at               DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Save The Dates ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='SaveTheDates' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.SaveTheDates (
    std_id              BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id             BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    wedding_site_id     BIGINT          NULL REFERENCES dbo.WeddingSites(site_id),
    recipient_name      NVARCHAR(255)   NOT NULL,
    recipient_email     VARCHAR(255)    NOT NULL,
    sender_name         NVARCHAR(255)   NULL,
    rsvp_status         VARCHAR(50)     NOT NULL DEFAULT 'pending',  -- pending, accepted, declined
    token_hash          VARCHAR(512)    NULL,
    sent_at             DATETIME2       NULL,
    responded_at        DATETIME2       NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Guests ───────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Guests' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.Guests (
    guest_id                BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id                 BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    name                    NVARCHAR(255)   NOT NULL,
    email                   VARCHAR(255)    NULL,
    phone                   VARCHAR(50)     NULL,
    guest_group             NVARCHAR(100)   NULL,
    rsvp_status             VARCHAR(50)     NOT NULL DEFAULT 'pending',  -- pending, accepted, declined
    plus_one                BIT             NOT NULL DEFAULT 0,
    plus_one_name           NVARCHAR(255)   NULL,
    dietary_restrictions    NVARCHAR(500)   NULL,
    notes                   NVARCHAR(MAX)   NULL,
    created_at              DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at              DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Reception Tables (Seating Chart) ─────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ReceptionTables' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.ReceptionTables (
    table_id        BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id         BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    table_number    INT             NULL,
    table_name      NVARCHAR(100)   NULL,
    label           NVARCHAR(100)   NULL,
    capacity        INT             NULL DEFAULT 8,
    notes           NVARCHAR(500)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Wedding Party Members ─────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='WeddingPartyMembers' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.WeddingPartyMembers (
    member_id   BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    name        NVARCHAR(255)   NOT NULL,
    email       VARCHAR(255)    NULL,
    party_role  NVARCHAR(100)   NULL,
    party_side  NVARCHAR(100)   NULL,
    notes       NVARCHAR(MAX)   NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Thank You Cards ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ThankYouCards' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.ThankYouCards (
    card_id             BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id             BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    recipient_name      NVARCHAR(255)   NOT NULL,
    recipient_email     VARCHAR(255)    NULL,
    template            VARCHAR(100)    NULL,
    custom_message      NVARCHAR(MAX)   NULL,
    status              VARCHAR(50)     NOT NULL DEFAULT 'draft',  -- draft, sent
    sent_at             DATETIME2       NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Wedding Timelines ─────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='WeddingTimelines' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.WeddingTimelines (
    timeline_id BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    event_time  VARCHAR(20)     NULL,
    event_name  NVARCHAR(255)   NOT NULL,
    description NVARCHAR(MAX)   NULL,
    notes       NVARCHAR(MAX)   NULL,
    sort_order  INT             NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Honeymoons ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Honeymoons' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.Honeymoons (
    honeymoon_id        BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id             BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    destination         NVARCHAR(255)   NULL,
    start_date          DATE            NULL,
    end_date            DATE            NULL,
    estimated_budget    DECIMAL(12,2)   NULL,
    notes               NVARCHAR(MAX)   NULL,
    created_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Gift Registries ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='GiftRegistries' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.GiftRegistries (
    registry_id             BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id                 BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    registry_type           NVARCHAR(100)   NULL,
    physical_registry_link  NVARCHAR(500)   NULL,
    registry_details        NVARCHAR(MAX)   NULL,
    created_at              DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at              DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Budget Items ──────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='BudgetItems' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.BudgetItems (
    item_id         BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id         BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    category        NVARCHAR(100)   NULL,
    item_name       NVARCHAR(255)   NOT NULL,
    estimated_cost  DECIMAL(12,2)   NULL DEFAULT 0,
    actual_cost     DECIMAL(12,2)   NULL DEFAULT 0,
    deposit_paid    DECIMAL(12,2)   NULL DEFAULT 0,
    paid            BIT             NOT NULL DEFAULT 0,
    vendor_name     NVARCHAR(255)   NULL,
    notes           NVARCHAR(MAX)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ── Checklist Items ───────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='ChecklistItems' AND schema_id=SCHEMA_ID('dbo'))
CREATE TABLE dbo.ChecklistItems (
    item_id     BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    title       NVARCHAR(255)   NOT NULL,
    description NVARCHAR(MAX)   NULL,
    due_date    DATE            NULL,
    priority    VARCHAR(20)     NULL DEFAULT 'medium',  -- low, medium, high
    category    NVARCHAR(100)   NULL,
    is_complete BIT             NOT NULL DEFAULT 0,
    completed_at DATETIME2      NULL,
    created_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
);

-- ============================================================
-- Indexes for common lookups
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Users_email')
    CREATE INDEX IX_Users_email ON dbo.Users(email);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Users_username')
    CREATE INDEX IX_Users_username ON dbo.Users(username);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_EmailVerificationTokens_user_id')
    CREATE INDEX IX_EmailVerificationTokens_user_id ON dbo.EmailVerificationTokens(user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_PasswordResetTokens_user_id')
    CREATE INDEX IX_PasswordResetTokens_user_id ON dbo.PasswordResetTokens(user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_WeddingSites_user_id')
    CREATE INDEX IX_WeddingSites_user_id ON dbo.WeddingSites(user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_WeddingSites_slug')
    CREATE INDEX IX_WeddingSites_slug ON dbo.WeddingSites(slug);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Guests_user_id')
    CREATE INDEX IX_Guests_user_id ON dbo.Guests(user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_BudgetItems_user_id')
    CREATE INDEX IX_BudgetItems_user_id ON dbo.BudgetItems(user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VendorAnalytics_vendor_id')
    CREATE INDEX IX_VendorAnalytics_vendor_id ON dbo.VendorAnalytics(vendor_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_VendorMessages_vendor_id')
    CREATE INDEX IX_VendorMessages_vendor_id ON dbo.VendorMessages(vendor_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Vendors_status')
    CREATE INDEX IX_Vendors_status ON dbo.Vendors(status);
