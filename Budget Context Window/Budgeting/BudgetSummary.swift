import Foundation

struct BudgetSummary: Equatable {
    let monthKey: String
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

    var spendableBudgetCents: Int {
        budgetCents - fixedCostCents
    }

    var totalCommittedCents: Int {
        fixedCostCents + manualExpenseCents
    }

    var totalBudgetRemainingCents: Int {
        budgetCents - totalCommittedCents
    }

    var totalBudgetPercentUsed: Double {
        budgetCents > 0 ? Double(totalCommittedCents) / Double(budgetCents) : 0
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
        monthLabel: String,
        monthKey: String = ""
    ) -> BudgetSummary {
        let spendableBudgetCents = budgetCents - fixedCostCents
        let usedCents = manualExpenseCents
        let remainingCents = spendableBudgetCents - usedCents
        let percentUsed: Double
        if spendableBudgetCents > 0 {
            percentUsed = Double(usedCents) / Double(spendableBudgetCents)
        } else if budgetCents > 0 && fixedCostCents >= budgetCents {
            percentUsed = 1
        } else {
            percentUsed = 0
        }

        return BudgetSummary(
            monthKey: monthKey,
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
