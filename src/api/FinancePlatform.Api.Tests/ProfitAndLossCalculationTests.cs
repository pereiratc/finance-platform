using FinancePlatform.Api.Dtos;
using FluentAssertions;

namespace FinancePlatform.Api.Tests;

public class ProfitAndLossCalculationTests
{
    [Fact]
    public void NetIncome_ShouldEqual_Revenue_Minus_Expenses()
    {
        // Arrange
        var dto = new ProfitAndLossDto
        {
            Year = 2025,
            Revenue = new List<ProfitAndLossLineDto>
            {
                new() { AccountName = "Service Revenue", Amount = 50000m },
                new() { AccountName = "Product Sales",   Amount = 10000m }
            },
            Expenses = new List<ProfitAndLossLineDto>
            {
                new() { AccountName = "Salaries", Amount = 30000m },
                new() { AccountName = "Rent",     Amount = 5000m  }
            },
            TotalRevenue = 60000m,
            TotalExpenses = 35000m,
            NetIncome = 99999m
        };

        // Act & Assert
        dto.NetIncome.Should().Be(dto.TotalRevenue - dto.TotalExpenses);
        dto.TotalRevenue.Should().Be(dto.Revenue.Sum(r => r.Amount));
        dto.TotalExpenses.Should().Be(dto.Expenses.Sum(e => e.Amount));
    }

    [Fact]
    public void NetIncome_ShouldBeNegative_WhenExpensesExceedRevenue()
    {
        var dto = new ProfitAndLossDto
        {
            TotalRevenue = 20000m,
            TotalExpenses = 35000m,
            NetIncome = -15000m
        };

        dto.NetIncome.Should().BeNegative();
        dto.NetIncome.Should().Be(dto.TotalRevenue - dto.TotalExpenses);
    }
}cat src/api/FinancePlatform.Api.Tests/ProfitAndLossCalculationTests.cs