-- =============================================================================
-- Finance Platform - Sample Queries
-- =============================================================================
-- Use these to verify the data loaded correctly and to explore the model.
-- These will inform the API endpoints you'll build in Phase 1.
-- =============================================================================

USE FinancePlatformDb;
GO

-- =============================================================================
-- 1. Quick health check — counts per table
-- =============================================================================
SELECT 'AccountTypes' AS TableName, COUNT(*) AS [Row Count] FROM dbo.AccountTypes
UNION ALL
SELECT 'Accounts',     COUNT(*) FROM dbo.Accounts
UNION ALL
SELECT 'Categories',   COUNT(*) FROM dbo.Categories
UNION ALL
SELECT 'Transactions', COUNT(*) FROM dbo.Transactions
UNION ALL
SELECT 'Budgets',      COUNT(*) FROM dbo.Budgets;

-- =============================================================================
-- 2. Chart of accounts overview
-- =============================================================================
SELECT
    a.AccountCode,
    a.Name AS AccountName,
    at.Name AS AccountType,
    at.NormalBalance
FROM dbo.Accounts a
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
ORDER BY a.AccountCode;

-- =============================================================================
-- 3. Account balances (uses the view)
-- =============================================================================
SELECT
    AccountCode,
    AccountName,
    AccountType,
    TotalDebits,
    TotalCredits,
    Balance
FROM dbo.vw_AccountBalances
ORDER BY AccountCode;

-- =============================================================================
-- 4. Trial balance — debits must equal credits
-- =============================================================================
SELECT
    SUM(Amount) AS TotalDebits_FromTransactions
FROM dbo.Transactions;
-- Each transaction debits one account and credits another by the same amount,
-- so total debits == total credits == sum of all transaction amounts.

-- =============================================================================
-- 5. Profit & Loss for 2025
-- =============================================================================
-- Revenue
SELECT
    'Revenue' AS Section,
    a.Name AS AccountName,
    SUM(t.Amount) AS Amount
FROM dbo.Transactions t
    INNER JOIN dbo.Accounts a ON t.CreditAccountId = a.AccountId
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
WHERE at.Name = 'Revenue'
    AND YEAR(t.TransactionDate) = 2025
GROUP BY a.Name

UNION ALL

-- Expenses
SELECT
    'Expense',
    a.Name,
    SUM(t.Amount)
FROM dbo.Transactions t
    INNER JOIN dbo.Accounts a ON t.DebitAccountId = a.AccountId
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
WHERE at.Name = 'Expense'
    AND YEAR(t.TransactionDate) = 2025
GROUP BY a.Name

ORDER BY Section, AccountName;

-- =============================================================================
-- 6. Monthly revenue trend
-- =============================================================================
SELECT
    YEAR(t.TransactionDate) AS Year,
    MONTH(t.TransactionDate) AS Month,
    DATENAME(MONTH, t.TransactionDate) AS MonthName,
    SUM(t.Amount) AS Revenue
FROM dbo.Transactions t
    INNER JOIN dbo.Accounts a ON t.CreditAccountId = a.AccountId
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
WHERE at.Name = 'Revenue'
GROUP BY YEAR(t.TransactionDate), MONTH(t.TransactionDate), DATENAME(MONTH, t.TransactionDate)
ORDER BY Year, Month;

-- =============================================================================
-- 7. Monthly expense breakdown
-- =============================================================================
SELECT
    YEAR(t.TransactionDate) AS Year,
    MONTH(t.TransactionDate) AS Month,
    c.Name AS Category,
    SUM(t.Amount) AS Amount
FROM dbo.Transactions t
    INNER JOIN dbo.Categories c ON t.CategoryId = c.CategoryId
    INNER JOIN dbo.Accounts a ON t.DebitAccountId = a.AccountId
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
WHERE at.Name = 'Expense'
GROUP BY YEAR(t.TransactionDate), MONTH(t.TransactionDate), c.Name
ORDER BY Year, Month, Category;

-- =============================================================================
-- 8. Budget vs Actual (current month example)
-- =============================================================================
WITH ActualByCategory AS (
    SELECT
        c.CategoryId,
        c.Name AS Category,
        YEAR(t.TransactionDate) AS Year,
        MONTH(t.TransactionDate) AS Month,
        SUM(t.Amount) AS ActualAmount
    FROM dbo.Transactions t
        INNER JOIN dbo.Categories c ON t.CategoryId = c.CategoryId
    GROUP BY c.CategoryId, c.Name, YEAR(t.TransactionDate), MONTH(t.TransactionDate)
)
SELECT
    b.BudgetYear AS Year,
    b.BudgetMonth AS Month,
    c.Name AS Category,
    b.BudgetAmount AS Budget,
    COALESCE(a.ActualAmount, 0) AS Actual,
    b.BudgetAmount - COALESCE(a.ActualAmount, 0) AS Variance,
    CASE
        WHEN b.BudgetAmount = 0 THEN NULL
        ELSE (COALESCE(a.ActualAmount, 0) / b.BudgetAmount) * 100
    END AS PercentOfBudget
FROM dbo.Budgets b
    INNER JOIN dbo.Categories c ON b.CategoryId = c.CategoryId
    LEFT JOIN ActualByCategory a
        ON a.CategoryId = b.CategoryId
        AND a.Year = b.BudgetYear
        AND a.Month = b.BudgetMonth
WHERE b.BudgetYear = 2025
    AND b.BudgetMonth = 6  -- change this to inspect different months
ORDER BY Category;

-- =============================================================================
-- 9. Recent transactions (last 20)
-- =============================================================================
SELECT TOP 20
    TransactionDate,
    Description,
    Reference,
    Amount,
    DebitAccountName,
    CreditAccountName,
    CategoryName
FROM dbo.vw_TransactionDetails
ORDER BY TransactionDate DESC, TransactionId DESC;

-- =============================================================================
-- 10. Outstanding accounts receivable (uncollected revenue)
-- =============================================================================
SELECT
    Balance AS OutstandingReceivable
FROM dbo.vw_AccountBalances
WHERE AccountCode = '1100';

-- More detailed: which invoices haven't been paid
SELECT
    t.TransactionDate,
    t.Reference,
    t.Description,
    t.Amount,
    -- Find any matching payment by reference matching
    (SELECT TOP 1 p.TransactionDate
     FROM dbo.Transactions p
     WHERE p.Description LIKE '%' + t.Reference + '%'
       AND p.CreditAccountId = (SELECT AccountId FROM dbo.Accounts WHERE AccountCode = '1100')
    ) AS PaymentDate
FROM dbo.Transactions t
    INNER JOIN dbo.Accounts da ON t.DebitAccountId = da.AccountId
WHERE da.AccountCode = '1100'  -- Accounts Receivable
ORDER BY t.TransactionDate DESC;
