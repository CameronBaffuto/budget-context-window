import Foundation
import SwiftData

@MainActor
enum BudgetWindowStore {
    static func activeWindow(from windows: [BudgetWindow]) -> BudgetWindow? {
        windows.first { !$0.isArchived } ?? windows.first
    }

    static func activeWindowID(from windows: [BudgetWindow]) -> String {
        activeWindow(from: windows)?.windowID ?? BudgetWindow.defaultWindowID
    }

    static func ensureDefaultWindow(
        settings: [BudgetSettings],
        windows: [BudgetWindow],
        expenses: [Expense],
        fixedCosts: [FixedCost],
        snapshots: [BudgetMonthSnapshot],
        modelContext: ModelContext
    ) throws {
        let defaultWindowID = BudgetWindow.defaultWindowID

        if windows.isEmpty {
            let budgetCents = settings.first?.monthlyBudgetCents ?? BudgetEngine.defaultMonthlyBudgetCents
            modelContext.insert(BudgetWindow(
                windowID: defaultWindowID,
                name: "Monthly Budget",
                monthlyBudgetCents: budgetCents
            ))
        }

        for expense in expenses where expense.budgetWindowID.isEmpty {
            expense.budgetWindowID = defaultWindowID
        }

        for fixedCost in fixedCosts where fixedCost.budgetWindowID.isEmpty {
            fixedCost.budgetWindowID = defaultWindowID
        }

        for snapshot in snapshots where snapshot.budgetWindowID.isEmpty {
            snapshot.budgetWindowID = defaultWindowID
        }

        try modelContext.save()
    }
}
