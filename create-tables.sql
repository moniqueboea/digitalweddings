-- =============================================================
--  digitalweddings.love  –  Full Database Schema
--  Target: SQL Server (Azure SQL / SQL Server 2019+)
--  Run this once against a new, empty database.
-- =============================================================

USE digitalweddings;
GO

-- -------------------------------------------------------------
-- 1. USERS
-- -------------------------------------------------------------
CREATE TABLE dbo.Users (
    user_id              BIGINT        IDENTITY(1,1) NOT NULL,
    username             VARCHAR(60)   NOT NULL,
    first_name           NVARCHAR(100) NOT NULL,
    last_name            NVARCHAR(100) NOT NULL,
    email                VARCHAR(320)  NOT NULL,
    password_hash        VARCHAR(512)  NOT NULL,
    password_salt        VARCHAR(256)  NOT NULL,
    password_iterations  INT           NOT NULL DEFAULT 100000,
    password_algorithm   VARCHAR(20)   NOT NULL DEFAULT 'PBKDF2-SHA256',
    role                 VARCHAR(20)   NOT NULL DEFAULT 'user',
    is_active            BIT           NOT NULL DEFAULT 0,
    is_admin             BIT           NOT NULL DEFAULT 0,
    email_verified_at    DATETIME2(0)  NULL,
    last_login_at        DATETIME2(0)  NULL,
    total_budget         DECIMAL(12,2) NULL,
    created_at           DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at           DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Users        PRIMARY KEY (user_id),
    CONSTRAINT UQ_Users_Email  UNIQUE (email),
    CONSTRAINT UQ_Users_Name   UNIQUE (username),
    CONSTRAINT CK_Users_Role   CHECK (role IN ('user','vendor','admin'))
);
GO

-- -------------------------------------------------------------
-- 2. EMAIL VERIFICATION TOKENS
-- -------------------------------------------------------------
CREATE TABLE dbo.EmailVerificationTokens (
    token_id    BIGINT       IDENTITY(1,1) NOT NULL,
    user_id     BIGINT       NOT NULL,
    token_hash  VARCHAR(512) NOT NULL,
    expires_at  DATETIME2(0) NOT NULL,
    used_at     DATETIME2(0) NULL,
    created_at  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_EmailVerificationTokens PRIMARY KEY (token_id),
    CONSTRAINT FK_EVT_User FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 3. PASSWORD RESET TOKENS
-- -------------------------------------------------------------
CREATE TABLE dbo.PasswordResetTokens (
    token_id    BIGINT       IDENTITY(1,1) NOT NULL,
    user_id     BIGINT       NOT NULL,
    token_hash  VARCHAR(512) NOT NULL,
    expires_at  DATETIME2(0) NOT NULL,
    used_at     DATETIME2(0) NULL,
    created_at  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_PasswordResetTokens PRIMARY KEY (token_id),
    CONSTRAINT FK_PRT_User FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 4. VENDORS
-- -------------------------------------------------------------
CREATE TABLE dbo.Vendors (
    vendor_id      BIGINT         IDENTITY(1,1) NOT NULL,
    owner_user_id  BIGINT         NULL,
    business_name  NVARCHAR(200)  NOT NULL,
    email          VARCHAR(320)   NOT NULL,
    category       NVARCHAR(100)  NOT NULL,
    description    NVARCHAR(2000) NULL,
    location       NVARCHAR(200)  NULL,
    phone          VARCHAR(30)    NULL,
    website        NVARCHAR(500)  NULL,
    instagram_url  NVARCHAR(500)  NULL,
    facebook_url   NVARCHAR(500)  NULL,
    price_range    VARCHAR(20)    NULL,
    image_url      NVARCHAR(500)  NULL,
    status         VARCHAR(20)    NOT NULL DEFAULT 'pending',
    featured       BIT            NOT NULL DEFAULT 0,
    complimentary  BIT            NOT NULL DEFAULT 0,
    created_at     DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Vendors       PRIMARY KEY (vendor_id),
    CONSTRAINT FK_Vendors_Owner FOREIGN KEY (owner_user_id) REFERENCES dbo.Users (user_id) ON DELETE SET NULL,
    CONSTRAINT CK_Vendors_Status CHECK (status IN ('pending','approved','active','rejected'))
);
GO

-- -------------------------------------------------------------
-- 5. VENDOR REVIEWS
-- -------------------------------------------------------------
CREATE TABLE dbo.VendorReviews (
    vendor_review_id  BIGINT         IDENTITY(1,1) NOT NULL,
    vendor_id         BIGINT         NOT NULL,
    user_id           BIGINT         NOT NULL,
    rating            TINYINT        NOT NULL,
    review_text       NVARCHAR(2000) NULL,
    created_at        DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at        DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_VendorReviews       PRIMARY KEY (vendor_review_id),
    CONSTRAINT FK_VR_Vendor           FOREIGN KEY (vendor_id) REFERENCES dbo.Vendors (vendor_id) ON DELETE CASCADE,
    CONSTRAINT FK_VR_User             FOREIGN KEY (user_id)   REFERENCES dbo.Users   (user_id)   ON DELETE CASCADE,
    CONSTRAINT CK_VR_Rating           CHECK (rating BETWEEN 1 AND 5)
);
GO

-- -------------------------------------------------------------
-- 6. WEDDING SITES
-- -------------------------------------------------------------
CREATE TABLE dbo.WeddingSites (
    wedding_site_id        BIGINT         IDENTITY(1,1) NOT NULL,
    user_id                BIGINT         NOT NULL,
    slug                   VARCHAR(200)   NULL,
    template               VARCHAR(100)   NOT NULL DEFAULT 'classic_gold',
    published              BIT            NOT NULL DEFAULT 0,
    couple_name_1          NVARCHAR(100)  NULL,
    couple_name_2          NVARCHAR(100)  NULL,
    wedding_date           DATE           NULL,
    venue_name             NVARCHAR(200)  NULL,
    venue_address          NVARCHAR(500)  NULL,
    reception_venue_name   NVARCHAR(200)  NULL,
    reception_venue_address NVARCHAR(500) NULL,
    story                  NVARCHAR(MAX)  NULL,
    scripture              NVARCHAR(MAX)  NULL,
    dress_code             NVARCHAR(200)  NULL,
    travel_info            NVARCHAR(MAX)  NULL,
    travel_info_link       NVARCHAR(500)  NULL,
    travel_links_json      NVARCHAR(MAX)  NULL,
    things_to_do           NVARCHAR(MAX)  NULL,
    things_to_do_link      NVARCHAR(500)  NULL,
    things_links_json      NVARCHAR(MAX)  NULL,
    faq_json               NVARCHAR(MAX)  NULL,
    hero_image_url         NVARCHAR(500)  NULL,
    couple_photo_url       NVARCHAR(500)  NULL,
    gallery_images_json    NVARCHAR(MAX)  NULL,
    created_at             DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at             DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_WeddingSites      PRIMARY KEY (wedding_site_id),
    CONSTRAINT FK_WS_User           FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE,
    CONSTRAINT UQ_WeddingSites_Slug UNIQUE (slug)
);
GO

-- -------------------------------------------------------------
-- 7. GUESTS
-- -------------------------------------------------------------
CREATE TABLE dbo.Guests (
    guest_id              BIGINT        IDENTITY(1,1) NOT NULL,
    user_id               BIGINT        NOT NULL,
    name                  NVARCHAR(200) NOT NULL,
    email                 VARCHAR(320)  NULL,
    phone                 VARCHAR(30)   NULL,
    guest_group           NVARCHAR(100) NULL,
    rsvp_status           VARCHAR(20)   NOT NULL DEFAULT 'pending',
    plus_one              BIT           NOT NULL DEFAULT 0,
    plus_one_name         NVARCHAR(200) NULL,
    dietary_restrictions  NVARCHAR(500) NULL,
    notes                 NVARCHAR(1000) NULL,
    table_number          INT           NULL,
    created_at            DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at            DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Guests         PRIMARY KEY (guest_id),
    CONSTRAINT FK_Guests_User    FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE,
    CONSTRAINT CK_Guests_Rsvp    CHECK (rsvp_status IN ('pending','attending','declined','maybe'))
);
GO

-- -------------------------------------------------------------
-- 8. RECEPTION TABLES  (seating chart)
-- -------------------------------------------------------------
CREATE TABLE dbo.ReceptionTables (
    reception_table_id  BIGINT        IDENTITY(1,1) NOT NULL,
    user_id             BIGINT        NOT NULL,
    table_number        INT           NOT NULL,
    label               NVARCHAR(100) NULL,
    table_name          NVARCHAR(100) NULL,
    capacity            INT           NULL,
    notes               NVARCHAR(500) NULL,
    created_at          DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ReceptionTables    PRIMARY KEY (reception_table_id),
    CONSTRAINT FK_RT_User            FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 9. WEDDING TIMELINES
-- -------------------------------------------------------------
CREATE TABLE dbo.WeddingTimelines (
    timeline_id   BIGINT         IDENTITY(1,1) NOT NULL,
    user_id       BIGINT         NOT NULL,
    event_time    VARCHAR(10)    NOT NULL,
    event_name    NVARCHAR(200)  NOT NULL,
    description   NVARCHAR(1000) NULL,
    notes         NVARCHAR(1000) NULL,
    created_at    DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_WeddingTimelines PRIMARY KEY (timeline_id),
    CONSTRAINT FK_WT_User          FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 10. BUDGET ITEMS
-- -------------------------------------------------------------
CREATE TABLE dbo.BudgetItems (
    budget_item_id  BIGINT         IDENTITY(1,1) NOT NULL,
    user_id         BIGINT         NOT NULL,
    category        NVARCHAR(100)  NOT NULL,
    item_name       NVARCHAR(200)  NOT NULL,
    estimated_cost  DECIMAL(12,2)  NULL,
    actual_cost     DECIMAL(12,2)  NULL,
    paid            BIT            NOT NULL DEFAULT 0,
    vendor_name     NVARCHAR(200)  NULL,
    notes           NVARCHAR(1000) NULL,
    created_at      DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_BudgetItems PRIMARY KEY (budget_item_id),
    CONSTRAINT FK_BI_User     FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 11. CHECKLIST ITEMS
-- -------------------------------------------------------------
CREATE TABLE dbo.ChecklistItems (
    checklist_item_id  BIGINT         IDENTITY(1,1) NOT NULL,
    user_id            BIGINT         NOT NULL,
    title              NVARCHAR(200)  NOT NULL,
    description        NVARCHAR(1000) NULL,
    due_date           DATE           NULL,
    priority           VARCHAR(10)    NOT NULL DEFAULT 'medium',
    category           NVARCHAR(100)  NULL,
    completed          BIT            NOT NULL DEFAULT 0,
    created_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ChecklistItems       PRIMARY KEY (checklist_item_id),
    CONSTRAINT FK_CI_User              FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE,
    CONSTRAINT CK_CI_Priority          CHECK (priority IN ('low','medium','high'))
);
GO

-- -------------------------------------------------------------
-- 12. GIFT REGISTRIES
-- -------------------------------------------------------------
CREATE TABLE dbo.GiftRegistries (
    gift_registry_id       BIGINT         IDENTITY(1,1) NOT NULL,
    user_id                BIGINT         NOT NULL,
    registry_type          VARCHAR(50)    NULL,
    physical_registry_link NVARCHAR(500)  NULL,
    registry_details       NVARCHAR(MAX)  NULL,
    created_at             DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at             DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_GiftRegistries PRIMARY KEY (gift_registry_id),
    CONSTRAINT FK_GR_User        FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 13. HONEYMOONS
-- -------------------------------------------------------------
CREATE TABLE dbo.Honeymoons (
    honeymoon_id       BIGINT         IDENTITY(1,1) NOT NULL,
    user_id            BIGINT         NOT NULL,
    destination        NVARCHAR(200)  NULL,
    start_date         DATE           NULL,
    end_date           DATE           NULL,
    estimated_budget   DECIMAL(12,2)  NULL,
    notes              NVARCHAR(MAX)  NULL,
    created_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Honeymoons PRIMARY KEY (honeymoon_id),
    CONSTRAINT FK_HM_User    FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE
);
GO

-- -------------------------------------------------------------
-- 14. WEDDING PARTY MEMBERS
-- -------------------------------------------------------------
CREATE TABLE dbo.WeddingPartyMembers (
    wedding_party_member_id  BIGINT         IDENTITY(1,1) NOT NULL,
    user_id                  BIGINT         NOT NULL,
    name                     NVARCHAR(200)  NOT NULL,
    email                    VARCHAR(320)   NULL,
    party_role               NVARCHAR(100)  NULL,
    party_side               VARCHAR(20)    NULL,
    notes                    NVARCHAR(1000) NULL,
    accepted                 VARCHAR(20)    NOT NULL DEFAULT 'pending',
    created_at               DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at               DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_WeddingPartyMembers PRIMARY KEY (wedding_party_member_id),
    CONSTRAINT FK_WPM_User            FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE,
    CONSTRAINT CK_WPM_Side            CHECK (party_side IN ('bride','groom','neutral',NULL))
);
GO

-- -------------------------------------------------------------
-- 15. SAVE THE DATES
-- -------------------------------------------------------------
CREATE TABLE dbo.SaveTheDates (
    save_the_date_id  BIGINT        IDENTITY(1,1) NOT NULL,
    user_id           BIGINT        NOT NULL,
    wedding_site_id   BIGINT        NOT NULL,
    recipient_name    NVARCHAR(200) NOT NULL,
    recipient_email   VARCHAR(320)  NOT NULL,
    sender_name       NVARCHAR(200) NULL,
    rsvp_status       VARCHAR(20)   NOT NULL DEFAULT 'pending',
    sent_at           DATETIME2(0)  NULL,
    created_at        DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at        DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_SaveTheDates    PRIMARY KEY (save_the_date_id),
    CONSTRAINT FK_STD_User        FOREIGN KEY (user_id)         REFERENCES dbo.Users        (user_id)         ON DELETE CASCADE,
    CONSTRAINT FK_STD_WeddingSite FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites (wedding_site_id),
    CONSTRAINT CK_STD_Rsvp       CHECK (rsvp_status IN ('pending','attending','declined'))
);
GO

-- -------------------------------------------------------------
-- 16. THANK YOU CARDS
-- -------------------------------------------------------------
CREATE TABLE dbo.ThankYouCards (
    thank_you_card_id  BIGINT         IDENTITY(1,1) NOT NULL,
    user_id            BIGINT         NOT NULL,
    recipient_name     NVARCHAR(200)  NOT NULL,
    recipient_email    VARCHAR(320)   NULL,
    template           VARCHAR(100)   NULL,
    custom_message     NVARCHAR(MAX)  NULL,
    status             VARCHAR(20)    NOT NULL DEFAULT 'draft',
    sent_date          DATE           NULL,
    created_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ThankYouCards   PRIMARY KEY (thank_you_card_id),
    CONSTRAINT FK_TYC_User        FOREIGN KEY (user_id) REFERENCES dbo.Users (user_id) ON DELETE CASCADE,
    CONSTRAINT CK_TYC_Status      CHECK (status IN ('draft','sent'))
);
GO

-- =============================================================
--  INDEXES  (frequently filtered / joined columns)
-- =============================================================
CREATE INDEX IX_Users_Email              ON dbo.Users                (email);
CREATE INDEX IX_EVT_UserId              ON dbo.EmailVerificationTokens (user_id);
CREATE INDEX IX_PRT_UserId              ON dbo.PasswordResetTokens     (user_id);
CREATE INDEX IX_Vendors_Status          ON dbo.Vendors               (status);
CREATE INDEX IX_VendorReviews_VendorId  ON dbo.VendorReviews         (vendor_id);
CREATE INDEX IX_WeddingSites_UserId     ON dbo.WeddingSites           (user_id);
CREATE INDEX IX_WeddingSites_Slug       ON dbo.WeddingSites           (slug);
CREATE INDEX IX_Guests_UserId           ON dbo.Guests                (user_id);
CREATE INDEX IX_Guests_Table            ON dbo.Guests                (user_id, table_number);
CREATE INDEX IX_RT_UserId               ON dbo.ReceptionTables       (user_id);
CREATE INDEX IX_WT_UserId               ON dbo.WeddingTimelines      (user_id);
CREATE INDEX IX_BI_UserId               ON dbo.BudgetItems           (user_id);
CREATE INDEX IX_CI_UserId               ON dbo.ChecklistItems        (user_id);
CREATE INDEX IX_GR_UserId               ON dbo.GiftRegistries        (user_id);
CREATE INDEX IX_HM_UserId               ON dbo.Honeymoons            (user_id);
CREATE INDEX IX_WPM_UserId              ON dbo.WeddingPartyMembers   (user_id);
CREATE INDEX IX_STD_UserId              ON dbo.SaveTheDates          (user_id);
CREATE INDEX IX_TYC_UserId              ON dbo.ThankYouCards         (user_id);
GO

-- =============================================================
--  SEED: set yourself as admin after running
-- =============================================================
-- UPDATE dbo.Users SET is_admin = 1 WHERE email = 'moniqueboea@gmail.com';
