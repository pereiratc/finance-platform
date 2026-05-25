namespace FinancePlatform.Api.Dtos;

public class ProfitAndLossDto
{
    public int Year { get; set; }
    public List<ProfitAndLossLineDto> Revenue { get; set; } = new();
    public List<ProfitAndLossLineDto> Expenses { get; set; } = new();
    public decimal TotalRevenue { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal NetIncome { get; set; }
}

public class ProfitAndLossLineDto
{
    public string AccountName { get; set; } = null!;
    public decimal Amount { get; set; }
}