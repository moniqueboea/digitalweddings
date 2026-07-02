/*
    Optional sample data.

    First register an account through the ColdFusion API, then replace the
    email below with that account's email and run this script once.
*/

SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @DemoEmail VARCHAR(320) = 'replace-with-your-email@example.com';
DECLARE @UserId BIGINT;

SELECT @UserId = user_id
FROM dbo.Users
WHERE email = @DemoEmail;

IF @UserId IS NULL
    THROW 50001, 'Register the demo user first and update @DemoEmail.', 1;

IF NOT EXISTS (SELECT 1 FROM dbo.Guests WHERE user_id = @UserId)
BEGIN
    INSERT INTO dbo.Guests
        (user_id, name, email, guest_group, rsvp_status, plus_one, plus_one_name,
         dietary_restrictions, table_number, rehearsal_dinner_rsvp)
    VALUES
        (@UserId, N'Alicia Johnson', 'alicia@example.com', N'Bride''s Family',
         'attending', 1, N'Marcus Johnson', N'Vegetarian', 1, 'accepted'),
        (@UserId, N'Darius Williams', 'darius@example.com', N'Groom''s Friends',
         'pending', 0, NULL, NULL, 2, 'pending'),
        (@UserId, N'Nia Robinson', 'nia@example.com', N'Mutual Friends',
         'attending', 0, NULL, N'Gluten-free', 1, 'accepted');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.BudgetItems WHERE user_id = @UserId)
BEGIN
    INSERT INTO dbo.BudgetItems
        (user_id, category, item_name, estimated_cost, actual_cost, paid, vendor_name)
    VALUES
        (@UserId, N'Venue', N'Ceremony & reception venue', 8500, 8200, 1, N'The Grand Hall'),
        (@UserId, N'Photography', N'Wedding photography', 3200, 3200, 0, N'Golden Hour Studios'),
        (@UserId, N'Catering', N'Dinner service', 6000, 0, 0, N'Heritage Table');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ChecklistItems WHERE user_id = @UserId)
BEGIN
    INSERT INTO dbo.ChecklistItems
        (user_id, title, category, priority, completed)
    VALUES
        (@UserId, N'Book the venue', N'Venue', 'high', 1),
        (@UserId, N'Finalize the guest list', N'Other', 'high', 0),
        (@UserId, N'Schedule attire fittings', N'Attire', 'medium', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.WeddingTimelines WHERE user_id = @UserId)
BEGIN
    INSERT INTO dbo.WeddingTimelines
        (user_id, event_time, event_name, description)
    VALUES
        (@UserId, '14:00', N'Ceremony Begins', N'Guests seated by 1:45 PM'),
        (@UserId, '16:00', N'Cocktail Hour', N'Courtyard cocktails and portraits'),
        (@UserId, '17:00', N'Reception Begins', N'Grand entrance and dinner');
END;

COMMIT TRANSACTION;
