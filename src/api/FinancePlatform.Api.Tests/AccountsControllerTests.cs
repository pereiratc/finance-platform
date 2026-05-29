using FinancePlatform.Api.Controllers;
using FinancePlatform.Api.Data;
using FinancePlatform.Api.Models;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FinancePlatform.Api.Tests;

public class AccountsControllerTests
{
    private ApplicationDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var context = new ApplicationDbContext(options);

        var accountType = new AccountType
        {
            AccountTypeId = 1,
            Name = "Asset",
            NormalBalance = "D",
            SortOrder = 1
        };

        context.AccountTypes.Add(accountType);

        context.Accounts.AddRange(
            new Account
            {
                AccountId = 1,
                AccountCode = "1000",
                Name = "Cash - Operating Account",
                AccountTypeId = 1,
                IsActive = true
            },
            new Account
            {
                AccountId = 2,
                AccountCode = "1010",
                Name = "Cash - Savings",
                AccountTypeId = 1,
                IsActive = true
            }
        );

        context.SaveChanges();
        return context;
    }

    [Fact]
    public async Task GetAll_ReturnsAllAccounts_OrderedByAccountCode()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var controller = new AccountsController(context);

        // Act
        var result = await controller.GetAll();

        // Assert
        var okResult = result.Result as OkObjectResult;
        okResult.Should().BeNull(); // ActionResult<T> returns value directly, not OkObjectResult

        result.Value.Should().NotBeNull();
        result.Value!.Should().HaveCount(2);
        result.Value!.First().AccountCode.Should().Be("1000");
    }

    [Fact]
    public async Task GetById_ReturnsNotFound_WhenAccountDoesNotExist()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var controller = new AccountsController(context);

        // Act
        var result = await controller.GetById(999);

        // Assert
        result.Result.Should().BeOfType<NotFoundResult>();
    }

    [Fact]
    public async Task GetById_ReturnsAccount_WhenAccountExists()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var controller = new AccountsController(context);

        // Act
        var result = await controller.GetById(1);

        // Assert
        result.Value.Should().NotBeNull();
        result.Value!.AccountCode.Should().Be("1000");
        result.Value!.AccountType.Should().Be("Asset");
    }
}