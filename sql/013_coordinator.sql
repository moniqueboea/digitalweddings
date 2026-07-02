-- 013_coordinator.sql
-- Adds wedding coordinator contact fields to WeddingSites

ALTER TABLE dbo.WeddingSites
    ADD coord_name    NVARCHAR(100) NULL,
        coord_company NVARCHAR(150) NULL,
        coord_email   NVARCHAR(200) NULL,
        coord_phone   NVARCHAR(30)  NULL;
