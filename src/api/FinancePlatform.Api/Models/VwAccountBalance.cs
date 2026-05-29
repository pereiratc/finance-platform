using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public partial class VwAccountBalance
{
    public int AccountId { get; set; }

    public string AccountCode { get; set; } = null!;

    public string AccountName { get; set; } = null!;

    public string AccountType { get; set; } = null!;

    public string NormalBalance { get; set; } = null!;

    public decimal? TotalDebits { get; set; }

    public decimal? TotalCredits { get; set; }

    public decimal? Balance { get; set; }
}
