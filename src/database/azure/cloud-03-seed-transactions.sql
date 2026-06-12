-- =============================================================================
-- [AZURE-READY] Azure-ready TRANSACTIONS — one year of 2025 transactions
-- =============================================================================
-- Run this against the EXISTING FinancePlatformDb on your Azure SQL server.
--
-- Azure SQL Database does not support `USE <db>` or CREATE/DROP DATABASE, so the
-- local script's database-creation / USE preamble has been removed. In SSMS,
-- open this query FROM the FinancePlatformDb node (Databases > FinancePlatformDb
-- > New Query) so it runs in the right database — you cannot `USE` to switch.
--
-- Run order: cloud-01 -> cloud-02 -> cloud-03.
-- =============================================================================

-- =============================================================================
-- Capture account IDs for cleaner inserts
-- =============================================================================
DECLARE @CashOperating       INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000');
DECLARE @CashSavings         INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1010');
DECLARE @AccountsReceivable  INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100');
DECLARE @Equipment           INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1500');
DECLARE @AccountsPayable     INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2000');
DECLARE @CreditCard          INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100');
DECLARE @SalesTaxPayable     INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2200');
DECLARE @OwnerCapital        INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '3000');
DECLARE @ServiceRevenue      INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000');
DECLARE @ProductSales        INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4100');
DECLARE @InterestIncome      INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4200');
DECLARE @CostOfGoodsSold     INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5000');
DECLARE @Salaries            INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5100');
DECLARE @Rent                INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5200');
DECLARE @Utilities           INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5300');
DECLARE @OfficeSupplies      INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5400');
DECLARE @Software            INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5500');
DECLARE @Marketing           INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5600');
DECLARE @ProfessionalFees    INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5700');
DECLARE @Travel              INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5800');
DECLARE @BankFees            INT = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5900');

DECLARE @CatConsulting   INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Consulting Services');
DECLARE @CatSoftLic      INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Software Licensing');
DECLARE @CatSupport      INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Support Contracts');
DECLARE @CatOtherIncome  INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Other Income');
DECLARE @CatPayroll      INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Payroll');
DECLARE @CatRentUtil     INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Rent and Utilities');
DECLARE @CatTechnology   INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Technology');
DECLARE @CatMarketing    INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Marketing');
DECLARE @CatProfServ     INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Professional Services');
DECLARE @CatOfficeOps    INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Office Operations');
DECLARE @CatTravel       INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Travel');
DECLARE @CatBankFin      INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Bank and Finance');
DECLARE @CatCostOfSales  INT = (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Cost of Sales');

-- =============================================================================
-- Opening transactions (January 1, 2025)
-- =============================================================================
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId) VALUES
    ('2025-01-01', 'Opening cash balance - owner investment', 'OPEN-001', 75000.00, @CashOperating, @OwnerCapital, NULL),
    ('2025-01-01', 'Initial equipment purchase', 'EQP-001', 15000.00, @Equipment, @OwnerCapital, NULL);

-- =============================================================================
-- Monthly recurring expenses (12 months)
-- =============================================================================
-- Generate monthly rent, salaries, utilities, software, bank fees
DECLARE @Month INT = 1;

WHILE @Month <= 12
BEGIN
    DECLARE @MonthEnd DATE = EOMONTH(DATEFROMPARTS(2025, @Month, 1));
    DECLARE @MidMonth DATE = DATEFROMPARTS(2025, @Month, 15);
    DECLARE @MonthStart DATE = DATEFROMPARTS(2025, @Month, 1);
    DECLARE @MonthLabel NVARCHAR(20) = DATENAME(MONTH, @MonthStart) + ' 2025';

    -- Rent (1st of month)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (@MonthStart, 'Office rent - ' + @MonthLabel, 'RENT-' + FORMAT(@Month, '00'), 4200.00, @Rent, @CashOperating, @CatRentUtil);

    -- Salaries (15th and 30th/last day)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (@MidMonth, 'Payroll - 1st half ' + @MonthLabel, 'PR-' + FORMAT(@Month, '00') + 'A', 14000.00, @Salaries, @CashOperating, @CatPayroll);

    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (@MonthEnd, 'Payroll - 2nd half ' + @MonthLabel, 'PR-' + FORMAT(@Month, '00') + 'B', 14000.00, @Salaries, @CashOperating, @CatPayroll);

    -- Utilities (5th of month)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (DATEADD(DAY, 4, @MonthStart), 'Utilities and internet - ' + @MonthLabel, 'UTL-' + FORMAT(@Month, '00'),
            350.00 + (@Month % 4) * 25, @Utilities, @CashOperating, @CatRentUtil);

    -- Software subscriptions (10th of month)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (DATEADD(DAY, 9, @MonthStart), 'Software subscriptions - ' + @MonthLabel, 'SW-' + FORMAT(@Month, '00'),
            1850.00, @Software, @CreditCard, @CatTechnology);

    -- Bank fees (last day of month)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (@MonthEnd, 'Bank service charges - ' + @MonthLabel, 'BNK-' + FORMAT(@Month, '00'),
            45.00, @BankFees, @CashOperating, @CatBankFin);

    -- Interest income (last day of month)
    INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
    VALUES (@MonthEnd, 'Interest earned on savings - ' + @MonthLabel, 'INT-' + FORMAT(@Month, '00'),
            85.00 + (@Month * 5), @CashSavings, @InterestIncome, @CatOtherIncome);

    SET @Month = @Month + 1;
END
GO

-- =============================================================================
-- Revenue transactions (varying amounts by month, simulating seasonal patterns)
-- =============================================================================
-- Consulting revenue: 2-4 invoices per month
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
SELECT
    TransactionDate,
    Description,
    Reference,
    Amount,
    (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'),  -- AR
    (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000'),  -- Service Revenue
    (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Consulting Services')
FROM (VALUES
    -- January
    ('2025-01-08', 'Consulting - Acme Corp Q1 engagement',         'INV-2025-001', 18500.00),
    ('2025-01-22', 'Consulting - Beta Industries assessment',      'INV-2025-002', 12000.00),
    ('2025-01-28', 'Consulting - Gamma LLC strategy workshop',     'INV-2025-003',  8500.00),
    -- February
    ('2025-02-05', 'Consulting - Acme Corp Q1 continuation',       'INV-2025-004', 22000.00),
    ('2025-02-18', 'Consulting - Delta Co implementation phase 1', 'INV-2025-005', 15750.00),
    -- March
    ('2025-03-03', 'Consulting - Epsilon Inc audit',               'INV-2025-006', 28000.00),
    ('2025-03-15', 'Consulting - Acme Corp Q1 final',              'INV-2025-007', 19500.00),
    ('2025-03-26', 'Consulting - Zeta Group workshop series',      'INV-2025-008', 11000.00),
    -- April
    ('2025-04-08', 'Consulting - Delta Co implementation phase 2', 'INV-2025-009', 24000.00),
    ('2025-04-22', 'Consulting - Eta Holdings strategy review',    'INV-2025-010', 13500.00),
    -- May
    ('2025-05-06', 'Consulting - Theta Corp transformation',       'INV-2025-011', 32000.00),
    ('2025-05-20', 'Consulting - Iota Partners assessment',        'INV-2025-012', 9800.00),
    -- June
    ('2025-06-04', 'Consulting - Theta Corp continuation',         'INV-2025-013', 28500.00),
    ('2025-06-17', 'Consulting - Kappa Solutions onboarding',      'INV-2025-014', 16200.00),
    ('2025-06-28', 'Consulting - Lambda Tech advisory',            'INV-2025-015', 11500.00),
    -- July (summer slowdown)
    ('2025-07-09', 'Consulting - Mu Industries assessment',        'INV-2025-016', 14000.00),
    ('2025-07-23', 'Consulting - Nu Group workshops',              'INV-2025-017', 9500.00),
    -- August (summer slowdown)
    ('2025-08-06', 'Consulting - Xi Holdings strategy',            'INV-2025-018', 17500.00),
    ('2025-08-19', 'Consulting - Omicron Co audit',                'INV-2025-019', 21000.00),
    -- September (back-to-school spike)
    ('2025-09-04', 'Consulting - Pi Corp Q4 planning',             'INV-2025-020', 26000.00),
    ('2025-09-15', 'Consulting - Rho Industries transformation',   'INV-2025-021', 34000.00),
    ('2025-09-26', 'Consulting - Sigma LLC implementation',        'INV-2025-022', 18800.00),
    -- October
    ('2025-10-07', 'Consulting - Tau Group strategy',              'INV-2025-023', 22500.00),
    ('2025-10-20', 'Consulting - Upsilon Inc review',              'INV-2025-024', 15500.00),
    -- November
    ('2025-11-05', 'Consulting - Phi Partners Q1 prep',            'INV-2025-025', 28000.00),
    ('2025-11-18', 'Consulting - Chi Holdings audit',              'INV-2025-026', 19500.00),
    -- December (year-end planning)
    ('2025-12-03', 'Consulting - Psi Corp year-end review',        'INV-2025-027', 24000.00),
    ('2025-12-15', 'Consulting - Omega Industries 2026 planning',  'INV-2025-028', 31000.00)
) AS t(TransactionDate, Description, Reference, Amount);

-- Software licensing revenue (monthly)
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId)
SELECT
    DATEFROMPARTS(2025, m.Month, 5),
    'Software license sales - ' + DATENAME(MONTH, DATEFROMPARTS(2025, m.Month, 1)) + ' 2025',
    'LIC-2025-' + FORMAT(m.Month, '00'),
    CASE
        WHEN m.Month IN (1, 2)    THEN 9500.00
        WHEN m.Month IN (3, 4, 5) THEN 11500.00
        WHEN m.Month IN (6, 7, 8) THEN 8500.00
        ELSE 13000.00
    END,
    (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),  -- Cash
    (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4100'),  -- Product Sales
    (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Software Licensing')
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS m(Month);

-- Support contracts (quarterly)
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId) VALUES
    ('2025-01-15', 'Q1 support contract renewals',  'SUP-2025-Q1', 24000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Support Contracts')),
    ('2025-04-15', 'Q2 support contract renewals',  'SUP-2025-Q2', 27000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Support Contracts')),
    ('2025-07-15', 'Q3 support contract renewals',  'SUP-2025-Q3', 25500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Support Contracts')),
    ('2025-10-15', 'Q4 support contract renewals',  'SUP-2025-Q4', 29500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '4000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Support Contracts'));

-- Customer payments (collections of receivables) - throughout the year
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId) VALUES
    ('2025-02-12', 'Payment received - Acme Corp INV-001',     'PMT-001', 18500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL),
    ('2025-02-25', 'Payment received - Beta Industries INV-002', 'PMT-002', 12000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL),
    ('2025-03-10', 'Payment received - Acme Corp INV-004',     'PMT-003', 22000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL),
    ('2025-04-08', 'Payment received - Epsilon Inc INV-006',   'PMT-004', 28000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL),
    ('2025-05-15', 'Payment received - Delta Co INV-009',      'PMT-005', 24000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL),
    ('2025-06-22', 'Payment received - Theta Corp INV-011',    'PMT-006', 32000.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100'), NULL);
GO

-- =============================================================================
-- Variable monthly expenses (marketing, supplies, travel, professional fees)
-- =============================================================================
INSERT INTO dbo.Transactions (TransactionDate, Description, Reference, Amount, DebitAccountId, CreditAccountId, CategoryId) VALUES
    -- Q1 marketing push
    ('2025-01-18', 'LinkedIn ads campaign',           'MKT-001',  2800.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5600'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Marketing')),
    ('2025-02-14', 'Conference sponsorship - TechExpo', 'MKT-002', 4500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5600'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Marketing')),
    ('2025-03-22', 'Google Ads Q1',                   'MKT-003',  3200.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5600'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Marketing')),
    -- Office supplies
    ('2025-01-12', 'Office supplies - Staples',       'OFF-001',   485.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5400'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Office Operations')),
    ('2025-04-08', 'Office supplies and printer ink', 'OFF-002',   620.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5400'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Office Operations')),
    ('2025-09-15', 'Office supplies and furniture',   'OFF-003',  1250.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5400'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Office Operations')),
    -- Travel
    ('2025-02-20', 'Client trip to Montreal',         'TVL-001',  1850.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5800'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Travel')),
    ('2025-05-12', 'Conference travel - Vancouver',   'TVL-002',  3200.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5800'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Travel')),
    ('2025-09-18', 'Client visits - New York',        'TVL-003',  2400.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5800'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Travel')),
    ('2025-11-10', 'Industry conference - Toronto',   'TVL-004',  1650.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5800'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Travel')),
    -- Professional fees
    ('2025-04-25', 'Accountant - tax preparation',    'PRO-001',  3500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5700'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Professional Services')),
    ('2025-07-18', 'Legal review - client contracts', 'PRO-002',  2200.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5700'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Professional Services')),
    ('2025-10-22', 'Accountant - Q3 review',          'PRO-003',  1800.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '5700'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'),
        (SELECT CategoryId FROM dbo.Categories WHERE Name = 'Professional Services')),
    -- Credit card payments (paying off accumulated CC balance)
    ('2025-02-28', 'Credit card payment',             'CC-PMT-01', 5800.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'), NULL),
    ('2025-05-30', 'Credit card payment',             'CC-PMT-02', 7200.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'), NULL),
    ('2025-08-30', 'Credit card payment',             'CC-PMT-03', 6500.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'), NULL),
    ('2025-11-28', 'Credit card payment',             'CC-PMT-04', 8100.00,
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '2100'),
        (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1000'), NULL);
GO

-- =============================================================================
-- Summary
-- =============================================================================
DECLARE @TxCount INT = (SELECT COUNT(*) FROM dbo.Transactions);
DECLARE @TotalDebit DECIMAL(18,2) = (SELECT SUM(Amount) FROM dbo.Transactions);

PRINT '';
PRINT 'Transaction data seeded successfully.';
PRINT '  - Total transactions: ' + CAST(@TxCount AS NVARCHAR(10));
PRINT '  - Total transaction value: $' + FORMAT(@TotalDebit, 'N2');
PRINT '';
PRINT 'You can now run validation queries from queries/sample-queries.sql';
PRINT 'and connect Power BI Desktop to FinancePlatformDb.';
GO
