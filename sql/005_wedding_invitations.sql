SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.WeddingInvitations (
    invitation_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    wedding_site_id BIGINT NOT NULL,
    guest_id BIGINT NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    plus_one_allowed BIT NOT NULL CONSTRAINT DF_WeddingInvitations_PlusOne DEFAULT (0),
    sent_at DATETIME2(0) NULL,
    responded_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_WeddingInvitations_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_WeddingInvitations_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_WeddingInvitations_WeddingSites
        FOREIGN KEY (wedding_site_id) REFERENCES dbo.WeddingSites(wedding_site_id) ON DELETE CASCADE,
    CONSTRAINT FK_WeddingInvitations_Guests
        FOREIGN KEY (guest_id) REFERENCES dbo.Guests(guest_id),
    CONSTRAINT UQ_WeddingInvitations_Guest UNIQUE (guest_id),
    CONSTRAINT UQ_WeddingInvitations_Token UNIQUE (token_hash)
);

CREATE INDEX IX_WeddingInvitations_WeddingSite
    ON dbo.WeddingInvitations(wedding_site_id);

COMMIT TRANSACTION;
