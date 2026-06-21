import SwiftData
import SwiftUI

struct ExpenseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var name: String
    @State private var amountText: String
    @State private var date: Date
    @State private var categoryName: String
    @State private var showsValidationError = false

    private let expense: Expense?
    private let budgetWindowID: String

    init(expense: Expense? = nil, budgetWindowID: String = BudgetWindow.defaultWindowID) {
        self.expense = expense
        self.budgetWindowID = expense?.budgetWindowID ?? budgetWindowID
        _name = State(initialValue: expense?.name ?? "")
        _amountText = State(initialValue: expense.map { CurrencyFormatter.decimalText(for: $0.amountCents) } ?? "")
        _date = State(initialValue: expense?.date ?? .now)
        _categoryName = State(initialValue: expense?.categoryName ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Category") {
                    TextField("Optional", text: $categoryName)
                        .textInputAutocapitalization(.words)

                    if !categorySuggestions.isEmpty {
                        Menu("Choose Category", systemImage: "tag") {
                            Button("None") {
                                categoryName = ""
                            }

                            ForEach(categorySuggestions, id: \.self) { category in
                                Button(category) {
                                    categoryName = category
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(expense == nil ? "Add Expense" : "Edit Expense")
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
            .alert("Check Expense", isPresented: $showsValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enter a name and an amount greater than zero.")
            }
        }
    }

    private var categorySuggestions: [String] {
        ExpenseCategoryCatalog.suggestions(
            from: categories,
            budgetWindowID: budgetWindowID,
            including: categoryName
        )
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategoryName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let amountCents = CurrencyFormatter.cents(from: amountText),
              amountCents > 0 else {
            showsValidationError = true
            return
        }

        if let expense {
            expense.name = trimmedName
            expense.amountCents = amountCents
            expense.date = date
            expense.categoryName = trimmedCategoryName
        } else {
            modelContext.insert(Expense(
                budgetWindowID: budgetWindowID,
                name: trimmedName,
                amountCents: amountCents,
                date: date,
                categoryName: trimmedCategoryName
            ))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ExpenseEditorView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
