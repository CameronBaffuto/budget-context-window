//
//  ContentView.swift
//  Budget Context Window
//
//  Created by Cameron Baffuto on 6/20/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetSettings.createdAt) private var settings: [BudgetSettings]
    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]
    @Query(sort: \BudgetMonthSnapshot.monthStart, order: .reverse) private var monthSnapshots: [BudgetMonthSnapshot]

    @State private var presentedSheet: SheetDestination?
    @State private var importDraft: AppleCardImportDraft?
    @State private var isShowingAppleCardImporter = false
    @State private var showsImportError = false
    @State private var importErrorMessage = ""

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
                    Menu {
                        Button("Add Expense", systemImage: "plus") {
                            presentedSheet = .addExpense(activeWindowID)
                        }

                        Button("Import Apple Card CSV", systemImage: "square.and.arrow.down") {
                            isShowingAppleCardImporter = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Add or import expenses")
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
            .sheet(item: $importDraft) { draft in
                AppleCardImportReviewView(draft: draft) { transactions in
                    importTransactions(transactions)
                }
            }
            .fileImporter(
                isPresented: $isShowingAppleCardImporter,
                allowedContentTypes: [.commaSeparatedText, .plainText],
                allowsMultipleSelection: false,
                onCompletion: handleAppleCardImport
            )
            .alert("Import Failed", isPresented: $showsImportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importErrorMessage)
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

    private func handleAppleCardImport(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else {
                return
            }

            let canAccessFile = url.startAccessingSecurityScopedResource()
            defer {
                if canAccessFile {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let transactions = try AppleCardCSVImporter.transactions(from: data)
            let duplicateIdentifiers = Set(expenses.compactMap { expense in
                expense.importIdentifier.isEmpty ? nil : expense.importIdentifier
            })

            importDraft = AppleCardImportDraft(
                transactions: transactions,
                duplicateIdentifiers: duplicateIdentifiers
            )
        } catch {
            importErrorMessage = error.localizedDescription
            showsImportError = true
        }
    }

    private func importTransactions(_ transactions: [AppleCardTransaction]) {
        for transaction in transactions {
            modelContext.insert(Expense(
                budgetWindowID: activeWindowID,
                name: transaction.merchant,
                amountCents: transaction.amountCents,
                date: transaction.transactionDate,
                categoryName: transaction.category,
                importSource: AppleCardTransaction.importSource,
                importIdentifier: transaction.importIdentifier
            ))
        }

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
