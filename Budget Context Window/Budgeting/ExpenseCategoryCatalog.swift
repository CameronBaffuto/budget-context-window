import Foundation

enum ExpenseCategoryCatalog {
    static let appleWalletCategories = [
        "Food & Drinks",
        "Entertainment",
        "Shopping",
        "Travel",
        "Health",
        "Transportation",
        "Services"
    ]

    static func suggestions(
        from categories: [ExpenseCategory],
        budgetWindowID: String,
        including currentCategory: String = ""
    ) -> [String] {
        let storedCategories = categories
            .filter { $0.budgetWindowID == budgetWindowID }
            .map(\.name)

        return mergedCategories(storedCategories + [currentCategory])
    }

    static func mergedCategories(_ categories: [String]) -> [String] {
        var seen: Set<String> = []
        var merged: [String] = []

        for category in categories {
            let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmedCategory.lowercased()

            guard !trimmedCategory.isEmpty, !seen.contains(key) else {
                continue
            }

            seen.insert(key)
            merged.append(trimmedCategory)
        }

        return merged
    }
}
