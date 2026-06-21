import SwiftData
import SwiftUI

struct ExpenseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String
    @State private var amountText: String
    @State private var date: Date
    @State private var showsValidationError = false

    private let expense: Expense?
    private let budgetWindowID: String

    init(expense: Expense? = nil, budgetWindowID: String = BudgetWindow.defaultWindowID) {
        self.expense = expense
        self.budgetWindowID = expense?.budgetWindowID ?? budgetWindowID
        _name = State(initialValue: expense?.name ?? "")
        _amountText = State(initialValue: expense.map { CurrencyFormatter.decimalText(for: $0.amountCents) } ?? "")
        _date = State(initialValue: expense?.date ?? .now)
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

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
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
        } else {
            modelContext.insert(Expense(
                budgetWindowID: budgetWindowID,
                name: trimmedName,
                amountCents: amountCents,
                date: date
            ))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ExpenseEditorView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self], inMemory: true)
}
