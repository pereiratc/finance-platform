using FinancePlatform.Api.Data;
using FinancePlatform.Api.Dtos;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinancePlatform.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public TransactionsController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET api/transactions
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TransactionDto>>> GetAll(
        [FromQuery] int? year,
        [FromQuery] int? month,
        [FromQuery] int? accountId)
    {
        var query = _context.Transactions
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.Category)
            .AsQueryable();

        if (year.HasValue)
            query = query.Where(t => t.TransactionDate.Year == year.Value);

        if (month.HasValue)
            query = query.Where(t => t.TransactionDate.Month == month.Value);

        if (accountId.HasValue)
            query = query.Where(t =>
                t.DebitAccountId == accountId.Value ||
                t.CreditAccountId == accountId.Value);

        return await query
            .OrderByDescending(t => t.TransactionDate)
            .ThenByDescending(t => t.TransactionId)
            .Select(t => new TransactionDto
            {
                TransactionId = t.TransactionId,
                TransactionDate = t.TransactionDate,
                Description = t.Description,
                Reference = t.Reference,
                Amount = t.Amount,
                DebitAccountCode = t.DebitAccount.AccountCode,
                DebitAccountName = t.DebitAccount.Name,
                CreditAccountCode = t.CreditAccount.AccountCode,
                CreditAccountName = t.CreditAccount.Name,
                CategoryName = t.Category != null ? t.Category.Name : null,
                CreatedAt = t.CreatedAt
            })
            .ToListAsync();
    }

    // GET api/transactions/5
    [HttpGet("{id}")]
    public async Task<ActionResult<TransactionDto>> GetById(int id)
    {
        var transaction = await _context.Transactions
            .Include(t => t.DebitAccount)
            .Include(t => t.CreditAccount)
            .Include(t => t.Category)
            .Where(t => t.TransactionId == id)
            .Select(t => new TransactionDto
            {
                TransactionId = t.TransactionId,
                TransactionDate = t.TransactionDate,
                Description = t.Description,
                Reference = t.Reference,
                Amount = t.Amount,
                DebitAccountCode = t.DebitAccount.AccountCode,
                DebitAccountName = t.DebitAccount.Name,
                CreditAccountCode = t.CreditAccount.AccountCode,
                CreditAccountName = t.CreditAccount.Name,
                CategoryName = t.Category != null ? t.Category.Name : null,
                CreatedAt = t.CreatedAt
            })
            .FirstOrDefaultAsync();

        if (transaction is null)
            return NotFound();

        return transaction;
    }
}