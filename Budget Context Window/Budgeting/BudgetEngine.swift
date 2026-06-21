import Foundation

enum BudgetEngine {
    static let defaultMonthlyBudgetCents = 500_000

    static func summary(
        window: BudgetWindow?,
        expenses: [Expense],
        fixedCosts: [FixedCost],
        period: BudgetPeriod
    ) -> BudgetSummary {
        let windowID = window?.windowID ?? BudgetWindow.defaultWindowID

        return BudgetCalculator.summary(
            budgetCents: window?.monthlyBudgetCents ?? defaultMonthlyBudgetCents,
            fixedCostCents: enabledFixedCostCents(fixedCosts, windowID: windowID),
            manualExpenseCents: manualExpenseCents(expenses, in: period, windowID: windowID),
            monthLabel: period.label,
            monthKey: period.monthKey
        )
    }

    static func manualExpenses(_ expenses: [Expense], in period: BudgetPeriod, windowID: String) -> [Expense] {
        expenses.filter { $0.budgetWindowID == windowID && period.contains($0.date) }
    }

    static func fixedCosts(_ fixedCosts: [FixedCost], windowID: String) -> [FixedCost] {
        fixedCosts.filter { $0.budgetWindowID == windowID }
    }

    static func enabledFixedCosts(_ fixedCosts: [FixedCost], windowID: String) -> [FixedCost] {
        fixedCosts.filter { $0.budgetWindowID == windowID && $0.isEnabled }
    }

    private static func manualExpenseCents(_ expenses: [Expense], in period: BudgetPeriod, windowID: String) -> Int {
        manualExpenses(expenses, in: period, windowID: windowID).reduce(0) { $0 + $1.amountCents }
    }

    private static func enabledFixedCostCents(_ fixedCosts: [FixedCost], windowID: String) -> Int {
        enabledFixedCosts(fixedCosts, windowID: windowID).reduce(0) { $0 + $1.amountCents }
    }
}
