-- =============================================================================
-- Finance Platform - Schema
-- =============================================================================
-- Creates the FinancePlatformDb database and core tables.
-- Run this first. Safe to re-run (drops and recreates the database).
-- =============================================================================

USE master;
GO

-- Drop existing database if it exists (start fresh during dev)
IF DB_ID('FinancePlatformDb') IS NOT NULL
BEGIN
    ALTER DATABASE FinancePlatformDb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FinancePlatformDb;
END
GO

CREATE DATABASE FinancePlatformDb;
GO

USE FinancePlatformDb;
GO

-- =============================================================================
-- Lookup tables
-- =============================================================================

-- AccountTypes: the 5 fundamental accounting categories
CREATE TABLE dbo.AccountTypes (
    AccountTypeId   INT             NOT NULL PRIMARY KEY,
    Name            NVARCHAR(50)    NOT NULL UNIQUE,
    NormalBalance   CHAR(1)         NOT NULL CHECK (NormalBalance IN ('D', 'C')), -- Debit or Credit
    SortOrder       INT             NOT NULL
);
GO

-- =============================================================================
-- Core tables
-- =============================================================================

-- Accounts: the chart of accounts
CREATE TABLE dbo.Accounts (
    AccountId       INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountCode     NVARCHAR(20)    NOT NULL UNIQUE,
    Name            NVARCHAR(100)   NOT NULL,
    AccountTypeId   INT             NOT NULL,
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Accounts_AccountType
        FOREIGN KEY (AccountTypeId) REFERENCES dbo.AccountTypes(AccountTypeId)
);
GO

CREATE INDEX IX_Accounts_AccountTypeId ON dbo.Accounts(AccountTypeId);
GO

-- Categories: sub-classifications for revenue and expense reporting
CREATE TABLE dbo.Categories (
    CategoryId      INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(100)   NOT NULL UNIQUE,
    AccountTypeId   INT             NOT NULL,  -- ties to Revenue or Expense
    Description     NVARCHAR(500)   NULL,
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Categories_AccountType
        FOREIGN KEY (AccountTypeId) REFERENCES dbo.AccountTypes(AccountTypeId)
);
GO

CREATE INDEX IX_Categories_AccountTypeId ON dbo.Categories(AccountTypeId);
GO

-- Transactions: the double-entry journal
-- Each business transaction creates one row with a debit account and a credit account
CREATE TABLE dbo.Transactions (
    TransactionId   INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TransactionDate DATE            NOT NULL,
    Description     NVARCHAR(500)   NOT NULL,
    Reference       NVARCHAR(50)    NULL,         -- invoice number, check number, etc.
    Amount          DECIMAL(18, 2)  NOT NULL CHECK (Amount > 0),
    DebitAccountId  INT             NOT NULL,
    CreditAccountId INT             NOT NULL,
    CategoryId      INT             NULL,         -- optional, used for revenue/expense items
    CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Transactions_DebitAccount
        FOREIGN KEY (DebitAccountId) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT FK_Transactions_CreditAccount
        FOREIGN KEY (CreditAccountId) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT FK_Transactions_Category
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT CK_Transactions_DifferentAccounts
        CHECK (DebitAccountId <> CreditAccountId)
);
GO

CREATE INDEX IX_Transactions_TransactionDate ON dbo.Transactions(TransactionDate);
CREATE INDEX IX_Transactions_DebitAccountId ON dbo.Transactions(DebitAccountId);
CREATE INDEX IX_Transactions_CreditAccountId ON dbo.Transactions(CreditAccountId);
CREATE INDEX IX_Transactions_CategoryId ON dbo.Transactions(CategoryId);
GO

-- Budgets: monthly budget targets per category
CREATE TABLE dbo.Budgets (
    BudgetId        INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CategoryId      INT             NOT NULL,
    BudgetYear      INT             NOT NULL CHECK (BudgetYear BETWEEN 2020 AND 2100),
    BudgetMonth     INT             NOT NULL CHECK (BudgetMonth BETWEEN 1 AND 12),
    BudgetAmount    DECIMAL(18, 2)  NOT NULL CHECK (BudgetAmount >= 0),
    CreatedAt       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Budgets_Category
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT UQ_Budgets_CategoryYearMonth
        UNIQUE (CategoryId, BudgetYear, BudgetMonth)
);
GO

CREATE INDEX IX_Budgets_YearMonth ON dbo.Budgets(BudgetYear, BudgetMonth);
GO

-- =============================================================================
-- Views (handy for Power BI and reports)
-- =============================================================================

-- Simplified transaction view with all the joined names
CREATE OR ALTER VIEW dbo.vw_TransactionDetails AS
SELECT
    t.TransactionId,
    t.TransactionDate,
    YEAR(t.TransactionDate) AS TransactionYear,
    MONTH(t.TransactionDate) AS TransactionMonth,
    DATENAME(MONTH, t.TransactionDate) AS MonthName,
    t.Description,
    t.Reference,
    t.Amount,
    da.AccountCode AS DebitAccountCode,
    da.Name AS DebitAccountName,
    dat.Name AS DebitAccountType,
    ca.AccountCode AS CreditAccountCode,
    ca.Name AS CreditAccountName,
    cat.Name AS CreditAccountType,
    c.Name AS CategoryName,
    t.CreatedAt
FROM dbo.Transactions t
    INNER JOIN dbo.Accounts da ON t.DebitAccountId = da.AccountId
    INNER JOIN dbo.AccountTypes dat ON da.AccountTypeId = dat.AccountTypeId
    INNER JOIN dbo.Accounts ca ON t.CreditAccountId = ca.AccountId
    INNER JOIN dbo.AccountTypes cat ON ca.AccountTypeId = cat.AccountTypeId
    LEFT JOIN dbo.Categories c ON t.CategoryId = c.CategoryId;
GO

-- Account balances view
CREATE OR ALTER VIEW dbo.vw_AccountBalances AS
SELECT
    a.AccountId,
    a.AccountCode,
    a.Name AS AccountName,
    at.Name AS AccountType,
    at.NormalBalance,
    COALESCE(debits.TotalDebits, 0) AS TotalDebits,
    COALESCE(credits.TotalCredits, 0) AS TotalCredits,
    CASE
        WHEN at.NormalBalance = 'D'
        THEN COALESCE(debits.TotalDebits, 0) - COALESCE(credits.TotalCredits, 0)
        ELSE COALESCE(credits.TotalCredits, 0) - COALESCE(debits.TotalDebits, 0)
    END AS Balance
FROM dbo.Accounts a
    INNER JOIN dbo.AccountTypes at ON a.AccountTypeId = at.AccountTypeId
    LEFT JOIN (
        SELECT DebitAccountId AS AccountId, SUM(Amount) AS TotalDebits
        FROM dbo.Transactions
        GROUP BY DebitAccountId
    ) debits ON a.AccountId = debits.AccountId
    LEFT JOIN (
        SELECT CreditAccountId AS AccountId, SUM(Amount) AS TotalCredits
        FROM dbo.Transactions
        GROUP BY CreditAccountId
    ) credits ON a.AccountId = credits.AccountId;
GO

PRINT 'Schema created successfully.';
PRINT '  - Database: FinancePlatformDb';
PRINT '  - Tables: AccountTypes, Accounts, Categories, Transactions, Budgets';
PRINT '  - Views: vw_TransactionDetails, vw_AccountBalances';
PRINT '';
PRINT 'Next: run 02-seed-reference-data.sql';
GO
