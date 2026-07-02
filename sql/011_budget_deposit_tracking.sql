-- 011: Add deposit tracking to BudgetItems
-- Adds deposit_paid column; paid is now auto-derived when deposit >= estimated_cost

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'BudgetItems' AND COLUMN_NAME = 'deposit_paid'
)
BEGIN
    ALTER TABLE dbo.BudgetItems
        ADD deposit_paid DECIMAL(12,2) NOT NULL CONSTRAINT DF_BudgetItems_Deposit DEFAULT (0);

    -- Back-fill: items already marked paid get deposit_paid = actual_cost (or estimated_cost if actual is 0)
    UPDATE dbo.BudgetItems
    SET deposit_paid = CASE WHEN actual_cost > 0 THEN actual_cost ELSE estimated_cost END
    WHERE paid = 1;
END
GO
