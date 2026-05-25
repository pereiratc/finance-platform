using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public class Category
{
    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public int AccountTypeId { get; set; }

    public string? Description { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual AccountType AccountType { get; set; } = null!;

    public virtual ICollection<Budget> Budgets { get; set; } = new List<Budget>();

    public virtual ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
}
