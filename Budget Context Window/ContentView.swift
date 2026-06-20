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
    @Query(sort: \BudgetMonthSnapshot.monthStart, order: .reverse) private var monthSnapshots: [BudgetMonthSnapshot]

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

                    MonthHistoryListView(snapshots: monthSnapshots) { snapshot in
                        presentedSheet = .monthDetail(snapshot)
                    }
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
                case .monthDetail(let snapshot):
                    MonthHistoryDetailView(snapshot: snapshot)
                }
            }
            .onAppear {
                ensureSettings()
                updateCurrentMonthSnapshot(summary)
                BudgetWidgetSnapshotStore.write(summary)
            }
            .onChange(of: summary) { _, newSummary in
                updateCurrentMonthSnapshot(newSummary)
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

    private func updateCurrentMonthSnapshot(_ summary: BudgetSummary) {
        let monthStart = monthWindow.interval.start

        if let existingSnapshot = monthSnapshots.first(where: { $0.monthStart == monthStart }) {
            existingSnapshot.update(with: summary)
        } else {
            modelContext.insert(BudgetMonthSnapshot(monthStart: monthStart, summary: summary))
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ], inMemory: true)
}

private enum SheetDestination: Identifiable {
    case addExpense
    case editExpense(Expense)
    case settings
    case monthDetail(BudgetMonthSnapshot)

    var id: String {
        switch self {
        case .addExpense:
            "addExpense"
        case .editExpense(let expense):
            "editExpense-\(expense.persistentModelID)"
        case .settings:
            "settings"
        case .monthDetail(let snapshot):
            "monthDetail-\(snapshot.persistentModelID)"
        }
    }
}
