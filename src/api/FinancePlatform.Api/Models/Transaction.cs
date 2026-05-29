using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public class Transaction
{
    public int TransactionId { get; set; }

    public DateOnly TransactionDate { get; set; }

    public string Description { get; set; } = null!;

    public string? Reference { get; set; }

    public decimal Amount { get; set; }

    public int DebitAccountId { get; set; }

    public int CreditAccountId { get; set; }

    public int? CategoryId { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Category? Category { get; set; }

    public virtual Account CreditAccount { get; set; } = null!;

    public virtual Account DebitAccount { get; set; } = null!;
}
