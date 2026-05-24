-- =============================================================================
-- Finance Platform - Reference Data Seed
-- =============================================================================
-- Loads the chart of accounts, categories, and 2025 monthly budgets.
-- Run after 01-schema.sql.
-- =============================================================================

USE FinancePlatformDb;
GO

-- =============================================================================
-- AccountTypes (the 5 fundamental accounting categories)
-- =============================================================================
INSERT INTO dbo.AccountTypes (AccountTypeId, Name, NormalBalance, SortOrder) VALUES
    (1, 'Asset',     'D', 1),
    (2, 'Liability', 'C', 2),
    (3, 'Equity',    'C', 3),
    (4, 'Revenue',   'C', 4),
    (5, 'Expense',   'D', 5);
GO

-- =============================================================================
-- Accounts (the chart of accounts)
-- =============================================================================

-- Assets (1000-1999)
INSERT INTO dbo.Accounts (AccountCode, Name, AccountTypeId, Description) VALUES
    ('1000', 'Cash - Operating Account', 1, 'Primary business checking account'),
    ('1010', 'Cash - Savings',           1, 'Business savings account'),
    ('1100', 'Accounts Receivable',      1, 'Money owed to us by customers'),
    ('1200', 'Inventory',                1, 'Goods held for sale'),
    ('1500', 'Equipment',                1, 'Computers, furniture, machinery'),
    ('1510', 'Accumulated Depreciation - Equipment', 1, 'Contra-asset for equipment');

-- Liabilities (2000-2999)
INSERT INTO dbo.Accounts (AccountCode, Name, AccountTypeId, Description) VALUES
    ('2000', 'Accounts Payable',         2, 'Money we owe to suppliers'),
    ('2100', 'Credit Card',              2, 'Business credit card balance'),
    ('2200', 'Sales Tax Payable',        2, 'HST/GST collected, owed to CRA'),
    ('2300', 'Payroll Liabilities',      2, 'Wages and source deductions owed'),
    ('2500', 'Loan Payable',             2, 'Long-term business loan');

-- Equity (3000-3999)
INSERT INTO dbo.Accounts (AccountCode, Name, AccountTypeId, Description) VALUES
    ('3000', 'Owner Capital',            3, 'Owner investment in the business'),
    ('3100', 'Retained Earnings',        3, 'Accumulated profits');

-- Revenue (4000-4999)
INSERT INTO dbo.Accounts (AccountCode, Name, AccountTypeId, Description) VALUES
    ('4000', 'Service Revenue',          4, 'Income from consulting services'),
    ('4100', 'Product Sales',            4, 'Income from product sales'),
    ('4200', 'Interest Income',          4, 'Interest earned on bank balances');

-- Expenses (5000-5999)
INSERT INTO dbo.Accounts (AccountCode, Name, AccountTypeId, Description) VALUES
    ('5000', 'Cost of Goods Sold',       5, 'Direct cost of products sold'),
    ('5100', 'Salaries and Wages',       5, 'Employee compensation'),
    ('5200', 'Rent Expense',             5, 'Office and warehouse rent'),
    ('5300', 'Utilities',                5, 'Electricity, water, internet, phone'),
    ('5400', 'Office Supplies',          5, 'Stationery, printer ink, small items'),
    ('5500', 'Software Subscriptions',   5, 'SaaS tools, cloud services'),
    ('5600', 'Marketing and Advertising', 5, 'Ads, promotions, content'),
    ('5700', 'Professional Fees',        5, 'Accountant, lawyer, consultants'),
    ('5800', 'Travel and Meals',         5, 'Business travel and client meals'),
    ('5900', 'Bank Fees',                5, 'Bank service charges'),
    ('5950', 'Depreciation Expense',     5, 'Periodic equipment depreciation');
GO

-- =============================================================================
-- Categories (sub-classifications for reporting)
-- =============================================================================

-- Revenue categories (linked to Revenue type, AccountTypeId = 4)
INSERT INTO dbo.Categories (Name, AccountTypeId, Description) VALUES
    ('Consulting Services',  4, 'Professional consulting engagements'),
    ('Software Licensing',   4, 'Software product sales'),
    ('Support Contracts',    4, 'Ongoing support and maintenance'),
    ('Other Income',         4, 'Interest, miscellaneous');

-- Expense categories (linked to Expense type, AccountTypeId = 5)
INSERT INTO dbo.Categories (Name, AccountTypeId, Description) VALUES
    ('Payroll',              5, 'Salaries, wages, benefits'),
    ('Rent and Utilities',   5, 'Office rent, electricity, internet'),
    ('Technology',           5, 'Software subscriptions, cloud services, hardware'),
    ('Marketing',            5, 'Advertising, content, promotions'),
    ('Professional Services', 5, 'Accounting, legal, consulting fees'),
    ('Office Operations',    5, 'Supplies, office equipment'),
    ('Travel',               5, 'Business travel, client meals'),
    ('Bank and Finance',     5, 'Bank fees, interest paid'),
    ('Cost of Sales',        5, 'Direct cost of goods/services sold');
GO

-- =============================================================================
-- 2025 Monthly Budgets (realistic small consulting business)
-- =============================================================================

-- Helper variables
DECLARE @BudgetYear INT = 2025;
DECLARE @Month INT = 1;

WHILE @Month <= 12
BEGIN
    -- Revenue budgets
    INSERT INTO dbo.Budgets (CategoryId, BudgetYear, BudgetMonth, BudgetAmount)
    SELECT CategoryId, @BudgetYear, @Month,
        CASE Name
            WHEN 'Consulting Services'  THEN 45000.00
            WHEN 'Software Licensing'   THEN 12000.00
            WHEN 'Support Contracts'    THEN 8000.00
            WHEN 'Other Income'         THEN  500.00
        END
    FROM dbo.Categories
    WHERE Name IN ('Consulting Services', 'Software Licensing', 'Support Contracts', 'Other Income');

    -- Expense budgets
    INSERT INTO dbo.Budgets (CategoryId, BudgetYear, BudgetMonth, BudgetAmount)
    SELECT CategoryId, @BudgetYear, @Month,
        CASE Name
            WHEN 'Payroll'              THEN 28000.00
            WHEN 'Rent and Utilities'   THEN  4500.00
            WHEN 'Technology'           THEN  2200.00
            WHEN 'Marketing'            THEN  3000.00
            WHEN 'Professional Services' THEN  1500.00
            WHEN 'Office Operations'    THEN   800.00
            WHEN 'Travel'               THEN  2000.00
            WHEN 'Bank and Finance'     THEN   300.00
            WHEN 'Cost of Sales'        THEN  6000.00
        END
    FROM dbo.Categories
    WHERE Name IN (
        'Payroll', 'Rent and Utilities', 'Technology', 'Marketing',
        'Professional Services', 'Office Operations', 'Travel',
        'Bank and Finance', 'Cost of Sales'
    );

    SET @Month = @Month + 1;
END
GO

PRINT 'Reference data seeded successfully.';
PRINT '  - 5 account types';
PRINT '  - 27 accounts in the chart of accounts';
PRINT '  - 13 categories (4 revenue, 9 expense)';
PRINT '  - 156 budget rows (13 categories x 12 months)';
PRINT '';
PRINT 'Next: run 03-seed-transactions.sql';
GO
