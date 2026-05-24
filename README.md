# Finance Platform

A fullstack financial reporting platform demonstrating the Microsoft enterprise stack: SQL Server, .NET API, React UI, Power BI analytics, deployed to Azure with CI/CD and Infrastructure as Code.

## Status

🚧 **In active development** — Phase 0: Foundation (database schema + seed data)

## Why this project

I built this to demonstrate end-to-end delivery on the modern Microsoft stack while modeling a domain I know well (financial reporting from my previous career as a finance manager). It is a single, complete artifact covering:

- Backend API (C# / .NET 10 / ASP.NET Core)
- Frontend (TypeScript / React)
- Database (SQL Server with Entity Framework Core)
- Analytics layer (Power BI with DAX)
- Cloud deployment (Azure Container Apps + Azure SQL)
- Automation (GitHub Actions CI/CD)
- Infrastructure as Code (Bicep templates)
- Observability (Application Insights + structured logging)

## Domain

The application tracks a small business's financial activity:

- **Accounts** — chart of accounts (Assets, Liabilities, Equity, Revenue, Expenses)
- **Categories** — sub-classifications for revenue and expense reporting
- **Transactions** — journal entries (debit/credit) with dates, amounts, and categorization
- **Budgets** — monthly budget targets per category
- **Reports** — P&L, cash flow, budget vs. actual

## Tech stack

| Layer | Technology |
|---|---|
| Backend | C# 14, .NET 10, ASP.NET Core, Entity Framework Core |
| Frontend | TypeScript, React 18, Vite, Tailwind CSS |
| Database | SQL Server 2025 / Azure SQL |
| Analytics | Power BI Desktop, DAX, Power Query |
| Cloud | Azure Container Apps, Azure SQL Database, Key Vault, Application Insights |
| CI/CD | GitHub Actions, GitHub Container Registry |
| IaC | Bicep |
| Containers | Docker, Docker Compose |
| Testing | xUnit, FluentAssertions, TestContainers |

## Running locally

> **Note**: Setup instructions will expand as each phase completes. Currently Phase 0 only.

### Prerequisites
- SQL Server 2025 Developer Edition (or any SQL Server 2022+)
- SSMS or VS Code with mssql extension

### Setup (Phase 0)
1. Open SSMS and connect to your local SQL Server instance
2. Run `src/database/01-schema.sql` to create the database and tables
3. Run `src/database/02-seed-reference-data.sql` to load accounts and categories
4. Run `src/database/03-seed-transactions.sql` to load sample transactions
5. Verify with `src/database/queries/sample-queries.sql`

## Project structure

```
finance-platform/
├── README.md
├── docs/
│   └── (architecture diagrams, design notes — coming in later phases)
└── src/
    └── database/
        ├── 01-schema.sql              # Tables, indexes, constraints
        ├── 02-seed-reference-data.sql # Accounts, categories
        ├── 03-seed-transactions.sql   # One year of sample transactions
        └── queries/
            └── sample-queries.sql     # Validation queries
```

## Roadmap

- [x] **Phase 0**: Database schema + seed data
- [ ] **Phase 1**: .NET 10 Web API + Docker
- [ ] **Phase 2**: GitHub Actions CI/CD
- [ ] **Phase 3**: React + TypeScript frontend
- [ ] **Phase 4**: Azure deployment (manual)
- [ ] **Phase 5**: Infrastructure as Code (Bicep)
- [ ] **Phase 6**: Power BI analytics layer
- [ ] **Phase 7**: Observability + production polish

## Author

Ferreira Pereira — Full Stack Developer in the Greater Toronto Area.

- GitHub: [@pereiratc](https://github.com/pereiratc)
- LinkedIn: [in/ferreira-pereira-18b9a23a](https://www.linkedin.com/in/ferreira-pereira-18b9a23a/)

## License

MIT
