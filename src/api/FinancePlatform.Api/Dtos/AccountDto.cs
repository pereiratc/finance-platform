namespace FinancePlatform.Api.Dtos;

public class AccountDto
{
    public int AccountId { get; set; }
    public string AccountCode { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string AccountType { get; set; } = null!;
    public string NormalBalance { get; set; } = null!;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}