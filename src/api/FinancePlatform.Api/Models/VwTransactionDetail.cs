using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public partial class VwTransactionDetail
{
    public int TransactionId { get; set; }

    public DateOnly TransactionDate { get; set; }

    public int? TransactionYear { get; set; }

    public int? TransactionMonth { get; set; }

    public string? MonthName { get; set; }

    public string Description { get; set; } = null!;

    public string? Reference { get; set; }

    public decimal Amount { get; set; }

    public string DebitAccountCode { get; set; } = null!;

    public string DebitAccountName { get; set; } = null!;

    public string DebitAccountType { get; set; } = null!;

    public string CreditAccountCode { get; set; } = null!;

    public string CreditAccountName { get; set; } = null!;

    public string CreditAccountType { get; set; } = null!;

    public string? CategoryName { get; set; }

    public DateTime CreatedAt { get; set; }
}
