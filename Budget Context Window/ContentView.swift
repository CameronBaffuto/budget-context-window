//
//  ContentView.swift
//  Budget Context Window
//
//  Created by Cameron Baffuto on 6/20/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetSettings.createdAt) private var settings: [BudgetSettings]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]

    @State private var presentedSheet: SheetDestination?

    private var monthWindow: MonthWindow {
        MonthWindow.current()
    }

    private var monthlyExpenses: [Expense] {
        expenses.filter { monthWindow.contains($0.date) }
    }

    private var enabledFixedCosts: [FixedCost] {
        fixedCosts.filter(\.isEnabled)
    }

    private var summary: BudgetSummary {
        BudgetCalculator.summary(
            budgetCents: settings.first?.monthlyBudgetCents ?? 500_000,
            fixedCostCents: enabledFixedCosts.reduce(0) { $0 + $1.amountCents },
            manualExpenseCents: monthlyExpenses.reduce(0) { $0 + $1.amountCents },
            monthLabel: monthWindow.label
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    BudgetGaugeView(summary: summary)

                    BudgetBreakdownView(summary: summary)

                    FixedCostsSummaryView(fixedCosts: fixedCosts)

                    MonthlyExpenseListView(
                        expenses: monthlyExpenses,
                        onEdit: { expense in
                            presentedSheet = .editExpense(expense)
                        },
                        onDelete: { expense in
                            deleteExpense(expense)
                        }
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget Window")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        presentedSheet = .settings
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Expense", systemImage: "plus") {
                        presentedSheet = .addExpense
                    }
                }
            }
            .sheet(item: $presentedSheet) { sheet in
                switch sheet {
                case .addExpense:
                    ExpenseEditorView()
                case .editExpense(let expense):
                    ExpenseEditorView(expense: expense)
                case .settings:
                    SettingsView()
                }
            }
            .onAppear {
                ensureSettings()
                BudgetWidgetSnapshotStore.write(summary)
            }
            .onChange(of: summary) { _, newSummary in
                BudgetWidgetSnapshotStore.write(newSummary)
            }
        }
    }

    private func ensureSettings() {
        guard settings.isEmpty else {
            return
        }

        modelContext.insert(BudgetSettings())
        try? modelContext.save()
    }

    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            BudgetSettings.self,
            Expense.self,
            FixedCost.self
        ], inMemory: true)
}

private enum SheetDestination: Identifiable {
    case addExpense
    case editExpense(Expense)
    case settings

    var id: String {
        switch self {
        case .addExpense:
            "addExpense"
        case .editExpense(let expense):
            "editExpense-\(expense.persistentModelID)"
        case .settings:
            "settings"
        }
    }
}
