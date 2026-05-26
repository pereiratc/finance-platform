# Finance Platform

A fullstack financial reporting platform demonstrating the Microsoft enterprise stack: SQL Server, .NET 10 API, React UI, Power BI analytics, deployed to Azure with CI/CD and Infrastructure as Code.

![CI](https://github.com/pereiratc/finance-platform/actions/workflows/api-ci.yml/badge.svg)
![CD](https://github.com/pereiratc/finance-platform/actions/workflows/api-cd.yml/badge.svg)

## Status

🚧 **In active development** — Phase 2 complete: .NET API + Docker + GitHub Actions CI/CD

## Why this project

I built this to demonstrate end-to-end delivery on the modern Microsoft stack while modeling a domain I know well — financial reporting from my previous career as a finance manager. It is a single, complete artifact covering:

- Backend API (C# / .NET 10 / ASP.NET Core)
- Frontend (TypeScript / React) — in progress
- Database (SQL Server with double-entry bookkeeping model)
- Analytics layer (Power BI with DAX) — in progress
- Cloud deployment (Azure Container Apps + Azure SQL) — in progress
- Automation (GitHub Actions CI/CD — active)
- Infrastructure as Code (Bicep) — in progress
- Observability (Application Insights + structured logging) — in progress

## Domain

The application tracks a small business's financial activity using a double-entry bookkeeping model — the same model required by IFRS and GAAP. Every transaction debits one account and credits another, enforced at the database level.

- **Accounts** — chart of accounts (Assets, Liabilities, Equity, Revenue, Expenses)
- **Categories** — sub-classifications for revenue and expense reporting
- **Transactions** — double-entry journal entries with dates, amounts, and categorization
- **Budgets** — monthly budget targets per category
- **Reports** — P&L summary, budget vs. actual variance analysis

## Tech stack

| Layer | Technology |
|---|---|
| Backend | C# 14, .NET 10, ASP.NET Core, Entity Framework Core |
| Frontend | TypeScript, React 18, Vite, Tailwind CSS *(in progress)* |
| Database | SQL Server 2025 / Azure SQL |
| Analytics | Power BI Desktop, DAX, Power Query *(in progress)* |
| Cloud | Azure Container Apps, Azure SQL Database, Key Vault, Application Insights *(in progress)* |
| CI/CD | GitHub Actions, GitHub Container Registry |
| IaC | Bicep *(in progress)* |
| Containers | Docker, Docker Compose |
| Testing | xUnit, FluentAssertions, EF InMemory |

## API endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/accounts` | All accounts ordered by account code |
| GET | `/api/accounts/{id}` | Single account by ID |
| GET | `/api/accounts/balances` | Account balances view |
| GET | `/api/transactions` | Transactions with optional `year`, `month`, `accountId` filters |
| GET | `/api/transactions/{id}` | Single transaction by ID |
| GET | `/api/reports/pnl?year=2025` | P&L summary — revenue, expenses, net income |
| GET | `/api/reports/budget-variance?year=2025&month=6` | Budget vs. actual variance by category |

## Running locally

### Option 1 — Docker (recommended)

Requires Docker Desktop.

```bash
git clone https://github.com/pereiratc/finance-platform.git
cd finance-platform
docker compose up --build
```

This starts three containers: SQL Server, a database init container that runs the seed scripts, and the API. On first run allow 3-5 minutes for SQL Server to initialize and the seed data to load.

Once running:
- API: `http://localhost:8080`
- Swagger: `http://localhost:8080/swagger`

### Option 2 — Local SQL Server

Requires SQL Server 2022+ and .NET 10 SDK.

```bash
git clone https://github.com/pereiratc/finance-platform.git
cd finance-platform
```

1. Open SSMS and connect to your local SQL Server instance
2. Run `src/database/01-schema.sql`
3. Run `src/database/02-seed-reference-data.sql`
4. Run `src/database/03-seed-transactions.sql`

Update the connection string in `src/api/FinancePlatform.Api/appsettings.json`, then:

```bash
dotnet run --project src/api/FinancePlatform.Api
```

Swagger available at the URL printed in the terminal output.

## CI/CD

Two GitHub Actions workflows run on every push:

**`api-ci.yml`** — triggers on pull requests to `main`:
- Restores dependencies
- Builds the .NET solution
- Runs all xUnit tests
- Fails the PR if any test fails

**`api-cd.yml`** — triggers on merge to `main`:
- Builds the Docker image (tests run inside the build stage)
- Pushes to GitHub Container Registry tagged with commit SHA and `main`

The Dockerfile uses a multi-stage build — the SDK image compiles and runs tests, the runtime image contains only the published output. A failing test stops the image from being created.

## Project structure

```
finance-platform/
├── .github/
│   └── workflows/
│       ├── api-ci.yml              # Build + test on PR
│       └── api-cd.yml              # Build image + push to GHCR on main
├── src/
│   ├── api/
│   │   ├── FinancePlatform.Api/
│   │   │   ├── Controllers/        # Accounts, Transactions, Reports
│   │   │   ├── Data/               # ApplicationDbContext
│   │   │   ├── Dtos/               # Response shapes (no circular refs)
│   │   │   ├── Models/             # EF entity classes
│   │   │   └── Dockerfile          # Multi-stage .NET build
│   │   └── FinancePlatform.Api.Tests/
│   │       └── (xUnit tests)
│   └── database/
│       ├── 01-schema.sql           # Tables, indexes, constraints, views
│       ├── 02-seed-reference-data.sql
│       ├── 03-seed-transactions.sql
│       └── queries/
│           └── sample-queries.sql
├── docker-compose.yml              # API + SQL Server + db-init
├── FinancePlatform.slnx
└── README.md
```

## Roadmap

- [x] **Phase 0** — Database schema + seed data (double-entry model, 153 transactions)
- [x] **Phase 1** — .NET 10 Web API + Docker (3 controllers, DTOs, multi-stage build)
- [x] **Phase 2** — GitHub Actions CI/CD (build, test, push to GHCR)
- [ ] **Phase 3** — React + TypeScript frontend
- [ ] **Phase 4** — Azure deployment (Container Apps, Azure SQL, Key Vault)
- [ ] **Phase 5** — Infrastructure as Code (Bicep)
- [ ] **Phase 6** — Power BI analytics layer
- [ ] **Phase 7** — Observability + production polish

## Author

Ferreira Pereira — Full Stack Developer in the Greater Toronto Area.

- GitHub: [@pereiratc](https://github.com/pereiratc)
- LinkedIn: [in/ferreira-pereira-18b9a23a](https://www.linkedin.com/in/ferreira-pereira-18b9a23a/)

## License

MIT
