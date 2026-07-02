SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.Users (
    user_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    username VARCHAR(30) COLLATE Latin1_General_100_CI_AS NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    email VARCHAR(320) COLLATE Latin1_General_100_CI_AS NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    password_salt VARCHAR(64) NOT NULL,
    password_iterations INT NOT NULL,
    password_algorithm VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL CONSTRAINT DF_Users_Role DEFAULT ('user'),
    is_active BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (0),
    email_verified_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSUTCDATETIME(),
    last_login_at DATETIME2(0) NULL,
    CONSTRAINT UQ_Users_Username UNIQUE (username),
    CONSTRAINT UQ_Users_Email UNIQUE (email),
    CONSTRAINT CK_Users_Role CHECK (role IN ('admin', 'user'))
);

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

CREATE TABLE dbo.Guests (
    guest_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name NVARCHAR(200) NOT NULL,
    email VARCHAR(320) NULL,
    phone VARCHAR(40) NULL,
    guest_group NVARCHAR(80) NULL,
    rsvp_status VARCHAR(20) NOT NULL CONSTRAINT DF_Guests_Rsvp DEFAULT ('pending'),
    plus_one BIT NOT NULL CONSTRAINT DF_Guests_PlusOne DEFAULT (0),
    plus_one_name NVARCHAR(200) NULL,
    dietary_restrictions NVARCHAR(1000) NULL,
    table_number INT NULL,
    notes NVARCHAR(MAX) NULL,
    rehearsal_dinner_invite_sent BIT NOT NULL CONSTRAINT DF_Guests_RehearsalSent DEFAULT (0),
    rehearsal_dinner_rsvp VARCHAR(20) NOT NULL CONSTRAINT DF_Guests_RehearsalRsvp DEFAULT ('pending'),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Guests_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Guests_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Guests_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_Guests_Rsvp CHECK (rsvp_status IN ('pending', 'attending', 'declined', 'maybe')),
    CONSTRAINT CK_Guests_RehearsalRsvp CHECK (rehearsal_dinner_rsvp IN ('pending', 'accepted', 'declined'))
);

CREATE INDEX IX_Guests_UserId ON dbo.Guests(user_id);

CREATE TABLE dbo.BudgetItems (
    budget_item_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category NVARCHAR(100) NOT NULL,
    item_name NVARCHAR(200) NOT NULL,
    estimated_cost DECIMAL(12,2) NOT NULL CONSTRAINT DF_BudgetItems_Estimated DEFAULT (0),
    actual_cost DECIMAL(12,2) NOT NULL CONSTRAINT DF_BudgetItems_Actual DEFAULT (0),
    paid BIT NOT NULL CONSTRAINT DF_BudgetItems_Paid DEFAULT (0),
    vendor_name NVARCHAR(200) NULL,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_BudgetItems_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_BudgetItems_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_BudgetItems_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE INDEX IX_BudgetItems_UserId ON dbo.BudgetItems(user_id);

CREATE TABLE dbo.ChecklistItems (
    checklist_item_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title NVARCHAR(250) NOT NULL,
    description NVARCHAR(MAX) NULL,
    due_date DATE NULL,
    completed BIT NOT NULL CONSTRAINT DF_ChecklistItems_Completed DEFAULT (0),
    priority VARCHAR(20) NOT NULL CONSTRAINT DF_ChecklistItems_Priority DEFAULT ('medium'),
    category NVARCHAR(100) NOT NULL CONSTRAINT DF_ChecklistItems_Category DEFAULT ('Other'),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_ChecklistItems_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_ChecklistItems_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ChecklistItems_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_ChecklistItems_Priority CHECK (priority IN ('low', 'medium', 'high'))
);

CREATE INDEX IX_ChecklistItems_UserId ON dbo.ChecklistItems(user_id);

CREATE TABLE dbo.WeddingTimelines (
    timeline_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    event_time TIME(0) NOT NULL,
    event_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NULL,
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingTimelines_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingTimelines_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WeddingTimelines_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE INDEX IX_WeddingTimelines_UserId ON dbo.WeddingTimelines(user_id);

CREATE TABLE dbo.RehearsalDinners (
    rehearsal_dinner_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    dinner_date DATE NULL,
    dinner_time TIME(0) NULL,
    location NVARCHAR(250) NOT NULL,
    address NVARCHAR(500) NULL,
    dress_code NVARCHAR(200) NULL,
    details NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_RehearsalDinners_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_RehearsalDinners_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_RehearsalDinners_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE INDEX IX_RehearsalDinners_UserId ON dbo.RehearsalDinners(user_id);

CREATE TABLE dbo.Honeymoons (
    honeymoon_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    destination NVARCHAR(250) NULL,
    start_date DATE NULL,
    end_date DATE NULL,
    estimated_budget DECIMAL(12,2) NOT NULL CONSTRAINT DF_Honeymoons_Budget DEFAULT (0),
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Honeymoons_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Honeymoons_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Honeymoons_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE TABLE dbo.GiftRegistries (
    gift_registry_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    registry_type VARCHAR(30) NOT NULL,
    physical_registry_link NVARCHAR(1000) NULL,
    registry_details NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_GiftRegistries_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_GiftRegistries_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_GiftRegistries_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_GiftRegistries_Type CHECK (registry_type IN ('honey_fund', 'physical_gifts'))
);

CREATE TABLE dbo.WeddingSites (
    wedding_site_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    template VARCHAR(50) NOT NULL,
    couple_name_1 NVARCHAR(150) NOT NULL,
    couple_name_2 NVARCHAR(150) NOT NULL,
    wedding_date DATE NULL,
    venue_name NVARCHAR(250) NULL,
    venue_address NVARCHAR(500) NULL,
    story NVARCHAR(MAX) NULL,
    scripture NVARCHAR(MAX) NULL,
    hero_image_url NVARCHAR(1000) NULL,
    gallery_images_json NVARCHAR(MAX) NULL,
    faq_json NVARCHAR(MAX) NULL,
    dress_code NVARCHAR(250) NULL,
    travel_info NVARCHAR(MAX) NULL,
    things_to_do NVARCHAR(MAX) NULL,
    published BIT NOT NULL CONSTRAINT DF_WeddingSites_Published DEFAULT (0),
    slug VARCHAR(150) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingSites_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingSites_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WeddingSites_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE INDEX IX_WeddingSites_UserId ON dbo.WeddingSites(user_id);
CREATE UNIQUE INDEX UX_WeddingSites_Slug
    ON dbo.WeddingSites(slug)
    WHERE slug IS NOT NULL;

CREATE TABLE dbo.ThankYouCards (
    thank_you_card_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    recipient_name NVARCHAR(200) NOT NULL,
    recipient_email VARCHAR(320) NOT NULL,
    template VARCHAR(30) NOT NULL,
    custom_message NVARCHAR(MAX) NULL,
    sent_date DATE NULL,
    status VARCHAR(20) NOT NULL CONSTRAINT DF_ThankYouCards_Status DEFAULT ('draft'),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_ThankYouCards_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_ThankYouCards_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ThankYouCards_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_ThankYouCards_Status CHECK (status IN ('draft', 'sent'))
);

CREATE TABLE dbo.Vendors (
    vendor_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    owner_user_id BIGINT NULL,
    business_name NVARCHAR(250) NOT NULL,
    category NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    location NVARCHAR(250) NOT NULL,
    phone VARCHAR(40) NULL,
    email VARCHAR(320) NOT NULL,
    website NVARCHAR(1000) NULL,
    price_range VARCHAR(10) NULL,
    image_url NVARCHAR(1000) NULL,
    featured BIT NOT NULL CONSTRAINT DF_Vendors_Featured DEFAULT (0),
    status VARCHAR(20) NOT NULL CONSTRAINT DF_Vendors_Status DEFAULT ('pending'),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Vendors_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Vendors_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Vendors_Users FOREIGN KEY (owner_user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_Vendors_Status CHECK (status IN ('pending', 'approved', 'rejected'))
);

CREATE TABLE dbo.VendorReviews (
    vendor_review_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    vendor_id BIGINT NOT NULL,
    user_id BIGINT NULL,
    reviewer_name NVARCHAR(200) NOT NULL,
    rating TINYINT NOT NULL,
    comment NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_VendorReviews_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_VendorReviews_Vendors FOREIGN KEY (vendor_id) REFERENCES dbo.Vendors(vendor_id) ON DELETE CASCADE,
    CONSTRAINT FK_VendorReviews_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_VendorReviews_Rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE dbo.WeddingPartyMembers (
    wedding_party_member_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name NVARCHAR(200) NOT NULL,
    email VARCHAR(320) NULL,
    party_role NVARCHAR(80) NOT NULL,
    party_side NVARCHAR(80) NULL,
    invite_sent BIT NOT NULL CONSTRAINT DF_WeddingPartyMembers_InviteSent DEFAULT (0),
    accepted VARCHAR(20) NOT NULL CONSTRAINT DF_WeddingPartyMembers_Accepted DEFAULT ('pending'),
    rehearsal_dinner_invite_sent BIT NOT NULL CONSTRAINT DF_WeddingPartyMembers_RehearsalSent DEFAULT (0),
    rehearsal_dinner_rsvp VARCHAR(20) NOT NULL CONSTRAINT DF_WeddingPartyMembers_RehearsalRsvp DEFAULT ('pending'),
    notes NVARCHAR(MAX) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingPartyMembers_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingPartyMembers_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WeddingPartyMembers_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE TABLE dbo.WeddingPartyRequirements (
    wedding_party_requirement_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    category NVARCHAR(80) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    notes NVARCHAR(MAX) NULL,
    photo_url NVARCHAR(1000) NULL,
    link_url NVARCHAR(1000) NULL,
    link_label NVARCHAR(200) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingPartyRequirements_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_WeddingPartyRequirements_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WeddingPartyRequirements_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE
);

CREATE TABLE dbo.ContactMessages (
    contact_message_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    email VARCHAR(320) NOT NULL,
    subject NVARCHAR(250) NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_ContactMessages_CreatedAt DEFAULT SYSUTCDATETIME()
);

COMMIT TRANSACTION;
