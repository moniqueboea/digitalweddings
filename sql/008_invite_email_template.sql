-- Add custom invite email fields to WeddingSites
ALTER TABLE dbo.WeddingSites
    ADD invite_subject  NVARCHAR(300) NULL,
        invite_message  NVARCHAR(MAX) NULL;
