import SwiftData
import SwiftUI

struct ExpenseCategoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]

    @State private var categoryName: String
    @State private var showsValidationError = false

    private let category: ExpenseCategory?
    private let budgetWindowID: String

    init(category: ExpenseCategory? = nil, budgetWindowID: String = BudgetWindow.defaultWindowID) {
        self.category = category
        self.budgetWindowID = category?.budgetWindowID ?? budgetWindowID
        _categoryName = State(initialValue: category?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    TextField("Name", text: $categoryName)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle(category == nil ? "Add Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .alert("Check Category", isPresented: $showsValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enter a unique category name.")
            }
        }
    }

    private func save() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !isDuplicate(trimmedName) else {
            showsValidationError = true
            return
        }

        do {
            if let category {
                try ExpenseCategoryStore.renameCategory(
                    category,
                    to: trimmedName,
                    expenses: expenses,
                    fixedCosts: fixedCosts,
                    modelContext: modelContext
                )
            } else {
                modelContext.insert(ExpenseCategory(budgetWindowID: budgetWindowID, name: trimmedName))
                try modelContext.save()
            }

            dismiss()
        } catch {
            showsValidationError = true
        }
    }

    private func isDuplicate(_ name: String) -> Bool {
        categories.contains { existingCategory in
            existingCategory.budgetWindowID == budgetWindowID
                && existingCategory.persistentModelID != category?.persistentModelID
                && existingCategory.name.normalizedCategoryName == name.normalizedCategoryName
        }
    }
}

#Preview {
    ExpenseCategoryEditorView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
