import Foundation

struct BudgetSummary: Equatable {
    let budgetCents: Int
    let fixedCostCents: Int
    let manualExpenseCents: Int
    let usedCents: Int
    let remainingCents: Int
    let percentUsed: Double
    let monthLabel: String

    var displayProgress: Double {
        min(max(percentUsed, 0), 1)
    }

    var isOverBudget: Bool {
        remainingCents < 0
    }

    var usageLevel: BudgetUsageLevel {
        BudgetUsageLevel(percentUsed: percentUsed)
    }
}

enum BudgetUsageLevel {
    case green
    case yellow
    case red

    init(percentUsed: Double) {
        if percentUsed <= 0.85 {
            self = .green
        } else if percentUsed < 0.99 {
            self = .yellow
        } else {
            self = .red
        }
    }
}

enum BudgetCalculator {
    static func summary(
        budgetCents: Int,
        fixedCostCents: Int,
        manualExpenseCents: Int,
        monthLabel: String
    ) -> BudgetSummary {
        let usedCents = fixedCostCents + manualExpenseCents
        let remainingCents = budgetCents - usedCents
        let percentUsed = budgetCents > 0 ? Double(usedCents) / Double(budgetCents) : 0

        return BudgetSummary(
            budgetCents: budgetCents,
            fixedCostCents: fixedCostCents,
            manualExpenseCents: manualExpenseCents,
            usedCents: usedCents,
            remainingCents: remainingCents,
            percentUsed: percentUsed,
            monthLabel: monthLabel
        )
    }
}
