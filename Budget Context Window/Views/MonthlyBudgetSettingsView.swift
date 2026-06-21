import SwiftData
import SwiftUI

struct MonthlyBudgetSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetSettings.createdAt) private var settings: [BudgetSettings]
    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]

    @State private var budgetText = ""
    @State private var showsValidationError = false

    private var activeWindow: BudgetWindow? {
        BudgetWindowStore.activeWindow(from: budgetWindows)
    }

    private var monthlyBudgetCents: Int {
        activeWindow?.monthlyBudgetCents ?? settings.first?.monthlyBudgetCents ?? BudgetEngine.defaultMonthlyBudgetCents
    }

    var body: some View {
        Form {
            Section("Monthly Budget") {
                TextField("Budget", text: $budgetText)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle("Monthly Budget")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveBudget()
                }
            }
        }
        .onAppear {
            budgetText = CurrencyFormatter.decimalText(for: monthlyBudgetCents)
        }
        .alert("Check Budget", isPresented: $showsValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enter a monthly budget greater than zero.")
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

        let budgetWindow = activeWindow ?? BudgetWindow(windowID: BudgetWindow.defaultWindowID)
        budgetWindow.monthlyBudgetCents = budgetCents
        budgetWindow.updatedAt = .now

        if activeWindow == nil {
            modelContext.insert(budgetWindow)
        }

        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        MonthlyBudgetSettingsView()
    }
    .modelContainer(for: [BudgetWindow.self, BudgetSettings.self], inMemory: true)
}
