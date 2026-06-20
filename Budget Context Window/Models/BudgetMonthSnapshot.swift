import Foundation
import SwiftData

@Model
final class BudgetMonthSnapshot {
    var monthStart: Date
    var monthLabel: String
    var budgetCents: Int
    var fixedCostCents: Int
    var manualExpenseCents: Int
    var usedCents: Int
    var remainingCents: Int
    var percentUsed: Double
    var updatedAt: Date

    init(monthStart: Date, summary: BudgetSummary, updatedAt: Date = .now) {
        self.monthStart = monthStart
        self.monthLabel = summary.monthLabel
        self.budgetCents = summary.budgetCents
        self.fixedCostCents = summary.fixedCostCents
        self.manualExpenseCents = summary.manualExpenseCents
        self.usedCents = summary.usedCents
        self.remainingCents = summary.remainingCents
        self.percentUsed = summary.percentUsed
        self.updatedAt = updatedAt
    }

    func update(with summary: BudgetSummary, updatedAt: Date = .now) {
        monthLabel = summary.monthLabel
        budgetCents = summary.budgetCents
        fixedCostCents = summary.fixedCostCents
        manualExpenseCents = summary.manualExpenseCents
        usedCents = summary.usedCents
        remainingCents = summary.remainingCents
        percentUsed = summary.percentUsed
        self.updatedAt = updatedAt
    }

    var displayProgress: Double {
        min(max(percentUsed, 0), 1)
    }

    var usageLevel: BudgetUsageLevel {
        BudgetUsageLevel(percentUsed: percentUsed)
    }
}
