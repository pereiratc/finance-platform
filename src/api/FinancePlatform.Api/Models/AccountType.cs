using System;
using System.Collections.Generic;

namespace FinancePlatform.Api.Models;

public class AccountType
{
    public int AccountTypeId { get; set; }

    public string Name { get; set; } = null!;

    public string NormalBalance { get; set; } = null!;

    public int SortOrder { get; set; }

    public virtual ICollection<Account> Accounts { get; set; } = new List<Account>();

    public virtual ICollection<Category> Categories { get; set; } = new List<Category>();
}
