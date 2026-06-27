SET XACT_ABORT ON;
BEGIN TRANSACTION;

CREATE TABLE dbo.ReceptionTables (
    reception_table_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    table_number INT NOT NULL,
    table_name NVARCHAR(100) NULL,
    capacity INT NULL,
    created_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_ReceptionTables_CreatedAt DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2(0) NOT NULL
        CONSTRAINT DF_ReceptionTables_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ReceptionTables_Users
        FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT UQ_ReceptionTables_UserNumber UNIQUE (user_id, table_number),
    CONSTRAINT CK_ReceptionTables_Number CHECK (table_number > 0),
    CONSTRAINT CK_ReceptionTables_Capacity CHECK (capacity IS NULL OR capacity > 0)
);

CREATE INDEX IX_ReceptionTables_UserId
    ON dbo.ReceptionTables(user_id);

INSERT INTO dbo.ReceptionTables (user_id, table_number)
SELECT DISTINCT g.user_id, g.table_number
FROM dbo.Guests g
WHERE g.table_number IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.ReceptionTables rt
      WHERE rt.user_id = g.user_id
        AND rt.table_number = g.table_number
  );

COMMIT TRANSACTION;
