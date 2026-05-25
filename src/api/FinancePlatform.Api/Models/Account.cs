using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public class Account
{
    public int AccountId { get; set; }

    public string AccountCode { get; set; } = null!;

    public string Name { get; set; } = null!;

    public int AccountTypeId { get; set; }

    public string? Description { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual AccountType AccountType { get; set; } = null!;

    public virtual ICollection<Transaction> CreditedTransactions{ get; set; } = new List<Transaction>();

    public virtual ICollection<Transaction> DebitedTransactions { get; set; } = new List<Transaction>();
}
