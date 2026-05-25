using FinancePlatform.Api.Data;
using FinancePlatform.Api.Dtos;
using FinancePlatform.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinancePlatform.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AccountsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AccountsController(ApplicationDbContext context)
    {
        _context = context;
    }

    // GET api/accounts
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AccountDto>>> GetAll()
    {
        return await _context.Accounts
            .Include(a => a.AccountType)
            .OrderBy(a => a.AccountCode)
            .Select(a => new AccountDto
            {
                AccountId = a.AccountId,
                AccountCode = a.AccountCode,
                Name = a.Name,
                AccountType = a.AccountType.Name,
                NormalBalance = a.AccountType.NormalBalance,
                Description = a.Description,
                IsActive = a.IsActive
            })
            .ToListAsync();
    }

    // GET api/accounts/5
    [HttpGet("{id}")]
    public async Task<ActionResult<AccountDto>> GetById(int id)
    {
        var account = await _context.Accounts
            .Include(a => a.AccountType)
            .Where(a => a.AccountId == id)
            .Select(a => new AccountDto
            {
                AccountId = a.AccountId,
                AccountCode = a.AccountCode,
                Name = a.Name,
                AccountType = a.AccountType.Name,
                NormalBalance = a.AccountType.NormalBalance,
                Description = a.Description,
                IsActive = a.IsActive
            })
            .FirstOrDefaultAsync();

        if (account is null)
            return NotFound();

        return account;
    }

    // GET api/accounts/balances
    [HttpGet("balances")]
    public async Task<ActionResult<IEnumerable<VwAccountBalance>>> GetBalances()
    {
        return await _context.VwAccountBalances
            .OrderBy(b => b.AccountCode)
            .ToListAsync();
    }
}