using FinancePlatform.Api.Data;
using FinancePlatform.Api.Dtos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinancePlatform.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReportsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ReportsController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET api/reports/pnl?year=2025
    [HttpGet("pnl")]
    public async Task<ActionResult<ProfitAndLossDto>> GetProfitAndLoss([FromQuery] int year = 2025)
    {
        // Revenue: transactions where the credited account is a Revenue type
        var revenue = await _context.Transactions
            .Where(t => t.TransactionDate.Year == year
                     && t.CreditAccount.AccountType.Name == "Revenue")
            .GroupBy(t => t.CreditAccount.Name)
            .Select(g => new ProfitAndLossLineDto
            {
                AccountName = g.Key,
                Amount = g.Sum(t => t.Amount)
            })
            .OrderBy(l => l.AccountName)
            .ToListAsync();

        // Expenses: transactions where the debited account is an Expense type
        var expenses = await _context.Transactions
            .Where(t => t.TransactionDate.Year == year
                     && t.DebitAccount.AccountType.Name == "Expense")
            .GroupBy(t => t.DebitAccount.Name)
            .Select(g => new ProfitAndLossLineDto
            {
                AccountName = g.Key,
                Amount = g.Sum(t => t.Amount)
            })
            .OrderBy(l => l.AccountName)
            .ToListAsync();

        var totalRevenue = revenue.Sum(r => r.Amount);
        var totalExpenses = expenses.Sum(e => e.Amount);

        return new ProfitAndLossDto
        {
            Year = year,
            Revenue = revenue,
            Expenses = expenses,
            TotalRevenue = totalRevenue,
            TotalExpenses = totalExpenses,
            NetIncome = totalRevenue - totalExpenses
        };
    }

    // GET api/reports/budget-variance?year=2025&month=6
    [HttpGet("budget-variance")]
    public async Task<ActionResult<BudgetVarianceDto>> GetBudgetVariance(
        [FromQuery] int year = 2025,
        [FromQuery] int month = 1)
    {
        if (month < 1 || month > 12)
            return BadRequest("Month must be between 1 and 12.");

        // Load budgets for the period
        var budgets = await _context.Budgets
            .Where(b => b.BudgetYear == year && b.BudgetMonth == month)
            .Select(b => new { b.Category.Name, b.BudgetAmount })
            .ToListAsync();

        // Load actuals for the period grouped by category
        var actuals = await _context.Transactions
            .Where(t => t.TransactionDate.Year == year
                     && t.TransactionDate.Month == month
                     && t.CategoryId != null)
            .GroupBy(t => t.Category!.Name)
            .Select(g => new { Category = g.Key, Actual = g.Sum(t => t.Amount) })
            .ToListAsync();

        // Join in memory — both sets are small
        var lines = budgets.Select(b =>
        {
            var actual = actuals.FirstOrDefault(a => a.Category == b.Name)?.Actual ?? 0m;
            return new BudgetVarianceLineDto
            {
                Category = b.Name,
                Budget = b.BudgetAmount,
                Actual = actual,
                Variance = b.BudgetAmount - actual,
                PercentOfBudget = b.BudgetAmount == 0
                    ? null
                    : Math.Round(actual / b.BudgetAmount * 100, 1)
            };
        })
        .OrderBy(l => l.Category)
        .ToList();

        return new BudgetVarianceDto
        {
            Year = year,
            Month = month,
            Lines = lines
        };
    }
}