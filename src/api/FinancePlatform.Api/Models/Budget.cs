using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public class Budget
{
    public int BudgetId { get; set; }

    public int CategoryId { get; set; }

    public int BudgetYear { get; set; }

    public int BudgetMonth { get; set; }

    public decimal BudgetAmount { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Category Category { get; set; } = null!;
}
