import Foundation
import SwiftData

@Model
final class BudgetMonthSnapshot {
    var budgetWindowID: String = BudgetWindow.defaultWindowID
    var monthKey: String = ""
    var monthStart: Date
    var monthLabel: String
    var budgetCents: Int
    var fixedCostCents: Int
    var manualExpenseCents: Int
    var usedCents: Int
    var remainingCents: Int
    var percentUsed: Double
    var updatedAt: Date

    init(
        budgetWindowID: String = BudgetWindow.defaultWindowID,
        monthStart: Date,
        summary: BudgetSummary,
        updatedAt: Date = .now
    ) {
        self.budgetWindowID = budgetWindowID
        self.monthKey = summary.monthKey.isEmpty ? BudgetPeriod.monthKey(for: monthStart) : summary.monthKey
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
        monthKey = summary.monthKey.isEmpty ? BudgetPeriod.monthKey(for: monthStart) : summary.monthKey
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

    var stableMonthKey: String {
        monthKey.isEmpty ? BudgetPeriod.monthKey(for: monthStart) : monthKey
    }
}
