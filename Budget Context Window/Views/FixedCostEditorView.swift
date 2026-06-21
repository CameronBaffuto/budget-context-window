import SwiftData
import SwiftUI

struct FixedCostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String
    @State private var amountText: String
    @State private var isEnabled: Bool
    @State private var showsValidationError = false

    private let fixedCost: FixedCost?
    private let budgetWindowID: String

    init(fixedCost: FixedCost? = nil, budgetWindowID: String = BudgetWindow.defaultWindowID) {
        self.fixedCost = fixedCost
        self.budgetWindowID = fixedCost?.budgetWindowID ?? budgetWindowID
        _name = State(initialValue: fixedCost?.name ?? "")
        _amountText = State(initialValue: fixedCost.map { CurrencyFormatter.decimalText(for: $0.amountCents) } ?? "")
        _isEnabled = State(initialValue: fixedCost?.isEnabled ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Fixed Cost") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    Toggle("Count in monthly budget", isOn: $isEnabled)
                }
            }
            .navigationTitle(fixedCost == nil ? "Add Fixed Cost" : "Edit Fixed Cost")
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
            .alert("Check Fixed Cost", isPresented: $showsValidationError) {
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

        if let fixedCost {
            fixedCost.name = trimmedName
            fixedCost.amountCents = amountCents
            fixedCost.isEnabled = isEnabled
        } else {
            modelContext.insert(FixedCost(
                budgetWindowID: budgetWindowID,
                name: trimmedName,
                amountCents: amountCents,
                isEnabled: isEnabled
            ))
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    FixedCostEditorView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self], inMemory: true)
}
