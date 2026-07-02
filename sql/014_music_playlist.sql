-- 014_music_playlist.sql
-- Wedding music playlist and DJ contact information

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- DJ contact info stored on WeddingSites
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_name')
    ALTER TABLE dbo.WeddingSites ADD dj_name       NVARCHAR(150) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_contact_person')
    ALTER TABLE dbo.WeddingSites ADD dj_contact_person NVARCHAR(150) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_email')
    ALTER TABLE dbo.WeddingSites ADD dj_email      NVARCHAR(320) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_phone')
    ALTER TABLE dbo.WeddingSites ADD dj_phone      NVARCHAR(30)  NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_website')
    ALTER TABLE dbo.WeddingSites ADD dj_website    NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='WeddingSites' AND COLUMN_NAME='dj_notes')
    ALTER TABLE dbo.WeddingSites ADD dj_notes      NVARCHAR(MAX) NULL;

-- Song playlist entries
IF OBJECT_ID('dbo.PlaylistSongs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PlaylistSongs (
        song_id       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id       BIGINT NOT NULL,
        playlist_type VARCHAR(20)   NOT NULL CONSTRAINT DF_PlaylistSongs_Type DEFAULT ('ceremony'),
        category      NVARCHAR(100) NOT NULL,
        sort_order    INT           NOT NULL CONSTRAINT DF_PlaylistSongs_Sort DEFAULT (0),
        song_title    NVARCHAR(300) NOT NULL,
        artist        NVARCHAR(300) NULL,
        notes         NVARCHAR(MAX) NULL,
        music_link    NVARCHAR(500) NULL,
        created_at    DATETIME2(0)  NOT NULL CONSTRAINT DF_PlaylistSongs_Created DEFAULT SYSUTCDATETIME(),
        updated_at    DATETIME2(0)  NOT NULL CONSTRAINT DF_PlaylistSongs_Updated DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PlaylistSongs_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
        CONSTRAINT CK_PlaylistSongs_Type CHECK (playlist_type IN ('ceremony','reception'))
    );
    CREATE INDEX IX_PlaylistSongs_UserId ON dbo.PlaylistSongs(user_id, playlist_type, category, sort_order);
END;

COMMIT TRANSACTION;
