-- ============================================================
-- Seed: Admin user - Monique Boea
-- Password: wedding@2026
-- Run ONCE in DBeaver after create-tables.sql
-- ============================================================

-- If user already exists, just promote to admin
IF EXISTS (
    SELECT 1 FROM dbo.Users
    WHERE username = 'moniqueboea' OR email = 'moniqueboea@gmail.com'
)
BEGIN
    UPDATE dbo.Users
    SET is_admin          = 1,
        is_active         = 1,
        role              = 'admin',
        email_verified_at = ISNULL(email_verified_at, SYSUTCDATETIME())
    WHERE username = 'moniqueboea' OR email = 'moniqueboea@gmail.com'

    PRINT 'Existing user updated to admin.'
END
ELSE
BEGIN
    INSERT INTO dbo.Users
        (username, first_name, last_name, email,
         password_hash, password_salt, password_iterations, password_algorithm,
         role, is_active, is_admin, email_verified_at)
    VALUES (
        'moniqueboea',
        'Monique',
        'Boea',
        'moniqueboea@gmail.com',
        '2B9ACC5BC1535021FC1F9614FD7F8B007D674FA93B52CE4CA58747B5014B04B0E004BAE31316CA47AB579C3225626B2AFB3C21FC8B45DFEB319FB654B6E53D97',
        'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
        120000,
        'SHA-512',
        'admin',
        1,
        1,
        SYSUTCDATETIME()
    )

    PRINT 'Admin user created.'
END
