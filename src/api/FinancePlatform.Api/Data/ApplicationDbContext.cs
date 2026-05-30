using System;
using System.Collections.Generic;
using FinancePlatform.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace FinancePlatform.Api.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext()
    {
    }

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Account> Accounts { get; set; }

    public virtual DbSet<AccountType> AccountTypes { get; set; }

    public virtual DbSet<Budget> Budgets { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Transaction> Transactions { get; set; }

    public virtual DbSet<VwAccountBalance> VwAccountBalances { get; set; }

    public virtual DbSet<VwTransactionDetail> VwTransactionDetails { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Account>(entity =>
        {
            entity.HasKey(e => e.AccountId).HasName("PK__Accounts__349DA5A69ECA8489");

            entity.HasIndex(e => e.AccountTypeId, "IX_Accounts_AccountTypeId");

            entity.HasIndex(e => e.AccountCode, "UQ__Accounts__38D0C56A4BA2EFEA").IsUnique();

            entity.Property(e => e.AccountCode).HasMaxLength(20);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);

            entity.HasOne(d => d.AccountType).WithMany(p => p.Accounts)
                .HasForeignKey(d => d.AccountTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Accounts_AccountType");
        });

        modelBuilder.Entity<AccountType>(entity =>
        {
            entity.HasKey(e => e.AccountTypeId).HasName("PK__AccountT__8F9585AFC898AFC5");

            entity.HasIndex(e => e.Name, "UQ__AccountT__737584F6743489B7").IsUnique();

            entity.Property(e => e.AccountTypeId).ValueGeneratedNever();
            entity.Property(e => e.Name).HasMaxLength(50);
            entity.Property(e => e.NormalBalance)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength();
        });

        modelBuilder.Entity<Budget>(entity =>
        {
            entity.HasKey(e => e.BudgetId).HasName("PK__Budgets__E38E792460CBEDEF");

            entity.HasIndex(e => new { e.BudgetYear, e.BudgetMonth }, "IX_Budgets_YearMonth");

            entity.HasIndex(e => new { e.CategoryId, e.BudgetYear, e.BudgetMonth }, "UQ_Budgets_CategoryYearMonth").IsUnique();

            entity.Property(e => e.BudgetAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())");

            entity.HasOne(d => d.Category).WithMany(p => p.Budgets)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Budgets_Category");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("PK__Categori__19093A0BA1115D62");

            entity.HasIndex(e => e.AccountTypeId, "IX_Categories_AccountTypeId");

            entity.HasIndex(e => e.Name, "UQ__Categori__737584F6FB990036").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);

            entity.HasOne(d => d.AccountType).WithMany(p => p.Categories)
                .HasForeignKey(d => d.AccountTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Categories_AccountType");
        });

        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.TransactionId).HasName("PK__Transact__55433A6BCEF9471E");

            entity.HasIndex(e => e.CategoryId, "IX_Transactions_CategoryId");

            entity.HasIndex(e => e.CreditAccountId, "IX_Transactions_CreditAccountId");

            entity.HasIndex(e => e.DebitAccountId, "IX_Transactions_DebitAccountId");

            entity.HasIndex(e => e.TransactionDate, "IX_Transactions_TransactionDate");

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Reference).HasMaxLength(50);

            entity.HasOne(d => d.Category).WithMany(p => p.Transactions)
                .HasForeignKey(d => d.CategoryId)
                .HasConstraintName("FK_Transactions_Category");

            entity.HasOne(d => d.CreditAccount).WithMany(p => p.CreditedTransactions)
                .HasForeignKey(d => d.CreditAccountId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Transactions_CreditAccount");

            entity.HasOne(d => d.DebitAccount).WithMany(p => p.DebitedTransactions)
                .HasForeignKey(d => d.DebitAccountId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Transactions_DebitAccount");
        });

        modelBuilder.Entity<VwAccountBalance>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_AccountBalances");

            entity.Property(e => e.AccountCode).HasMaxLength(20);
            entity.Property(e => e.AccountName).HasMaxLength(100);
            entity.Property(e => e.AccountType).HasMaxLength(50);
            entity.Property(e => e.Balance).HasColumnType("decimal(38, 2)");
            entity.Property(e => e.NormalBalance)
                .HasMaxLength(1)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.TotalCredits).HasColumnType("decimal(38, 2)");
            entity.Property(e => e.TotalDebits).HasColumnType("decimal(38, 2)");
        });

        modelBuilder.Entity<VwTransactionDetail>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_TransactionDetails");

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.CategoryName).HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasPrecision(0);
            entity.Property(e => e.CreditAccountCode).HasMaxLength(20);
            entity.Property(e => e.CreditAccountName).HasMaxLength(100);
            entity.Property(e => e.CreditAccountType).HasMaxLength(50);
            entity.Property(e => e.DebitAccountCode).HasMaxLength(20);
            entity.Property(e => e.DebitAccountName).HasMaxLength(100);
            entity.Property(e => e.DebitAccountType).HasMaxLength(50);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.MonthName).HasMaxLength(30);
            entity.Property(e => e.Reference).HasMaxLength(50);
        });
    }

}
