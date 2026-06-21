import Foundation

enum BudgetEngine {
    static let defaultMonthlyBudgetCents = 500_000

    static func summary(
        settings: BudgetSettings?,
        expenses: [Expense],
        fixedCosts: [FixedCost],
        period: BudgetPeriod
    ) -> BudgetSummary {
        BudgetCalculator.summary(
            budgetCents: settings?.monthlyBudgetCents ?? defaultMonthlyBudgetCents,
            fixedCostCents: enabledFixedCostCents(fixedCosts),
            manualExpenseCents: manualExpenseCents(expenses, in: period),
            monthLabel: period.label,
            monthKey: period.monthKey
        )
    }

    static func manualExpenses(_ expenses: [Expense], in period: BudgetPeriod) -> [Expense] {
        expenses.filter { period.contains($0.date) }
    }

    static func enabledFixedCosts(_ fixedCosts: [FixedCost]) -> [FixedCost] {
        fixedCosts.filter(\.isEnabled)
    }

    private static func manualExpenseCents(_ expenses: [Expense], in period: BudgetPeriod) -> Int {
        manualExpenses(expenses, in: period).reduce(0) { $0 + $1.amountCents }
    }

    private static func enabledFixedCostCents(_ fixedCosts: [FixedCost]) -> Int {
        enabledFixedCosts(fixedCosts).reduce(0) { $0 + $1.amountCents }
    }
}
