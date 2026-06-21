import Foundation
import SwiftData

@MainActor
enum ExpenseCategoryStore {
    static func activeCategories(_ categories: [ExpenseCategory], budgetWindowID: String) -> [ExpenseCategory] {
        categories
            .filter { $0.budgetWindowID == budgetWindowID }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func ensureDefaultsIfNeeded(
        categories: [ExpenseCategory],
        expenses: [Expense],
        budgetWindowID: String,
        modelContext: ModelContext
    ) throws {
        let activeCategories = activeCategories(categories, budgetWindowID: budgetWindowID)
        guard activeCategories.isEmpty else {
            return
        }

        let expenseCategories = expenses
            .filter { $0.budgetWindowID == budgetWindowID }
            .map(\.categoryName)
        let categoryNames = ExpenseCategoryCatalog.mergedCategories(
            ExpenseCategoryCatalog.appleWalletCategories + expenseCategories
        )

        insertMissingCategories(
            categoryNames,
            into: categories,
            budgetWindowID: budgetWindowID,
            modelContext: modelContext
        )
        try modelContext.save()
    }

    static func insertMissingCategories(
        _ names: [String],
        into categories: [ExpenseCategory],
        budgetWindowID: String,
        modelContext: ModelContext
    ) {
        var existingNames = Set(
            categories
                .filter { $0.budgetWindowID == budgetWindowID }
                .map { $0.name.normalizedCategoryName }
        )

        for name in ExpenseCategoryCatalog.mergedCategories(names) {
            let key = name.normalizedCategoryName
            guard !existingNames.contains(key) else {
                continue
            }

            modelContext.insert(ExpenseCategory(budgetWindowID: budgetWindowID, name: name))
            existingNames.insert(key)
        }
    }

    static func renameCategory(
        _ category: ExpenseCategory,
        to newName: String,
        expenses: [Expense],
        modelContext: ModelContext
    ) throws {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        let oldName = category.name
        category.name = trimmedName
        category.updatedAt = .now

        for expense in expenses where expense.budgetWindowID == category.budgetWindowID && expense.categoryName == oldName {
            expense.categoryName = trimmedName
        }

        try modelContext.save()
    }
}

extension String {
    var normalizedCategoryName: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
