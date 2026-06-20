import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetSettings.createdAt) private var settings: [BudgetSettings]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]

    @State private var budgetText = ""
    @State private var selectedFixedCost: FixedCost?
    @State private var isAddingFixedCost = false
    @State private var showsValidationError = false

    private var monthlyBudgetCents: Int {
        settings.first?.monthlyBudgetCents ?? 500_000
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Monthly Budget") {
                    TextField("Budget", text: $budgetText)
                        .keyboardType(.decimalPad)
                }

                Section("Fixed Costs") {
                    if fixedCosts.isEmpty {
                        ContentUnavailableView(
                            "No Fixed Costs",
                            systemImage: "calendar",
                            description: Text("Add recurring costs that should count every month.")
                        )
                    } else {
                        ForEach(fixedCosts) { fixedCost in
                            HStack {
                                Button {
                                    selectedFixedCost = fixedCost
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text(fixedCost.name)
                                                .foregroundStyle(.primary)

                                            Image(systemName: fixedCost.isEnabled ? "checkmark.circle.fill" : "circle")
                                                .font(.caption)
                                                .foregroundStyle(fixedCost.isEnabled ? .green : .secondary)
                                        }

                                        Text(CurrencyFormatter.dollarsText(for: fixedCost.amountCents))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                Menu {
                                    Button("Edit", systemImage: "pencil") {
                                        selectedFixedCost = fixedCost
                                    }

                                    Button(fixedCost.isEnabled ? "Disable" : "Enable", systemImage: fixedCost.isEnabled ? "pause.circle" : "checkmark.circle") {
                                        toggleFixedCost(fixedCost)
                                    }

                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        deleteFixedCost(fixedCost)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.large)
                                        .frame(width: 34, height: 34)
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Fixed cost actions for \(fixedCost.name)")
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteFixedCost(fixedCost)
                                }

                                Button(fixedCost.isEnabled ? "Disable" : "Enable", systemImage: fixedCost.isEnabled ? "pause.circle" : "checkmark.circle") {
                                    toggleFixedCost(fixedCost)
                                }
                                .tint(.blue)
                            }
                        }
                    }

                    Button("Add Fixed Cost", systemImage: "plus") {
                        isAddingFixedCost = true
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        saveBudget()
                    }
                }
            }
            .onAppear {
                budgetText = CurrencyFormatter.decimalText(for: monthlyBudgetCents)
            }
            .sheet(isPresented: $isAddingFixedCost) {
                FixedCostEditorView()
            }
            .sheet(item: $selectedFixedCost) { fixedCost in
                FixedCostEditorView(fixedCost: fixedCost)
            }
            .alert("Check Budget", isPresented: $showsValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enter a monthly budget greater than zero.")
            }
        }
    }

    private func saveBudget() {
        guard let budgetCents = CurrencyFormatter.cents(from: budgetText), budgetCents > 0 else {
            showsValidationError = true
            return
        }

        let budgetSettings = settings.first ?? BudgetSettings()
        budgetSettings.monthlyBudgetCents = budgetCents
        budgetSettings.updatedAt = .now

        if settings.isEmpty {
            modelContext.insert(budgetSettings)
        }

        try? modelContext.save()
        dismiss()
    }

    private func toggleFixedCost(_ fixedCost: FixedCost) {
        fixedCost.isEnabled.toggle()
        try? modelContext.save()
    }

    private func deleteFixedCost(_ fixedCost: FixedCost) {
        modelContext.delete(fixedCost)
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BudgetSettings.self, Expense.self, FixedCost.self], inMemory: true)
}
