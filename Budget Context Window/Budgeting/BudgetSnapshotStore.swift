import Foundation
import SwiftData

@MainActor
enum BudgetSnapshotStore {
    static func upsertCurrentMonthSnapshot(
        budgetWindowID: String,
        summary: BudgetSummary,
        period: BudgetPeriod,
        snapshots: [BudgetMonthSnapshot],
        modelContext: ModelContext
    ) throws {
        if let existingSnapshot = snapshots.first(where: { $0.budgetWindowID == budgetWindowID && $0.stableMonthKey == period.monthKey }) {
            existingSnapshot.update(with: summary)
        } else {
            modelContext.insert(BudgetMonthSnapshot(
                budgetWindowID: budgetWindowID,
                monthStart: period.interval.start,
                summary: summary
            ))
        }

        try modelContext.save()
    }
}
