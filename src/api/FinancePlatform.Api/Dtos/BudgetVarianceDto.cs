namespace FinancePlatform.Api.Dtos;

public class BudgetVarianceDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public List<BudgetVarianceLineDto> Lines { get; set; } = new();
}

public class BudgetVarianceLineDto
{
    public string Category { get; set; } = null!;
    public decimal Budget { get; set; }
    public decimal Actual { get; set; }
    public decimal Variance { get; set; }
    public decimal? PercentOfBudget { get; set; }
}