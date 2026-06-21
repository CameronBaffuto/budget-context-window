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
    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]
    @Query(sort: \BudgetMonthSnapshot.monthStart, order: .reverse) private var monthSnapshots: [BudgetMonthSnapshot]

    @State private var presentedSheet: SheetDestination?

    private var activeWindow: BudgetWindow? {
        BudgetWindowStore.activeWindow(from: budgetWindows)
    }

    private var activeWindowID: String {
        BudgetWindowStore.activeWindowID(from: budgetWindows)
    }

    private var currentPeriod: BudgetPeriod {
        BudgetPeriod.current(startDay: activeWindow?.cycleStartDay ?? 1)
    }

    private var monthlyExpenses: [Expense] {
        BudgetEngine.manualExpenses(expenses, in: currentPeriod, windowID: activeWindowID)
    }

    private var fixedCostsForActiveWindow: [FixedCost] {
        BudgetEngine.fixedCosts(fixedCosts, windowID: activeWindowID)
    }

    private var snapshotsForActiveWindow: [BudgetMonthSnapshot] {
        monthSnapshots.filter { $0.budgetWindowID == activeWindowID }
    }

    private var summary: BudgetSummary {
        BudgetEngine.summary(
            window: activeWindow,
            expenses: expenses,
            fixedCosts: fixedCosts,
            period: currentPeriod
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    BudgetGaugeView(summary: summary)

                    BudgetBreakdownView(summary: summary)

                    FixedCostsSummaryView(fixedCosts: fixedCostsForActiveWindow)

                    MonthlyExpenseListView(
                        expenses: monthlyExpenses,
                        onEdit: { expense in
                            presentedSheet = .editExpense(expense)
                        },
                        onDelete: { expense in
                            deleteExpense(expense)
                        }
                    )

                    MonthHistoryListView(snapshots: snapshotsForActiveWindow) { snapshot in
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
                        presentedSheet = .addExpense(activeWindowID)
                    }
                }
            }
            .sheet(item: $presentedSheet) { sheet in
                switch sheet {
                case .addExpense(let budgetWindowID):
                    ExpenseEditorView(budgetWindowID: budgetWindowID)
                case .editExpense(let expense):
                    ExpenseEditorView(expense: expense)
                case .settings:
                    SettingsView()
                case .monthDetail(let snapshot):
                    MonthHistoryDetailView(snapshot: snapshot)
                }
            }
            .onAppear {
                ensureDefaultWindow()
                ensureSettings()
                upsertCurrentMonthSnapshot(summary)
                BudgetWidgetSnapshotStore.write(summary)
            }
            .onChange(of: summary) { _, newSummary in
                upsertCurrentMonthSnapshot(newSummary)
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

    private func ensureDefaultWindow() {
        try? BudgetWindowStore.ensureDefaultWindow(
            settings: settings,
            windows: budgetWindows,
            expenses: expenses,
            fixedCosts: fixedCosts,
            snapshots: monthSnapshots,
            modelContext: modelContext
        )
    }

    private func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
    }

    private func upsertCurrentMonthSnapshot(_ summary: BudgetSummary) {
        try? BudgetSnapshotStore.upsertCurrentMonthSnapshot(
            budgetWindowID: activeWindowID,
            summary: summary,
            period: currentPeriod,
            snapshots: monthSnapshots,
            modelContext: modelContext
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            BudgetWindow.self,
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ], inMemory: true)
}

private enum SheetDestination: Identifiable {
    case addExpense(String)
    case editExpense(Expense)
    case settings
    case monthDetail(BudgetMonthSnapshot)

    var id: String {
        switch self {
        case .addExpense(let budgetWindowID):
            "addExpense-\(budgetWindowID)"
        case .editExpense(let expense):
            "editExpense-\(expense.persistentModelID)"
        case .settings:
            "settings"
        case .monthDetail(let snapshot):
            "monthDetail-\(snapshot.persistentModelID)"
        }
    }
}
