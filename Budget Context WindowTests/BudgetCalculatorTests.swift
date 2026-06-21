import Foundation
import SwiftData
import Testing
@testable import Budget_Context_Window

@Suite("Budget calculation")
struct BudgetCalculatorTests {
    @Test("Combines fixed and manual spending")
    func combinesFixedAndManualSpending() {
        let summary = BudgetCalculator.summary(
            budgetCents: 500_000,
            fixedCostCents: 275_000,
            manualExpenseCents: 50_000,
            monthLabel: "June 2026"
        )

        #expect(summary.usedCents == 325_000)
        #expect(summary.remainingCents == 175_000)
        #expect(summary.percentUsed == 0.65)
        #expect(summary.isOverBudget == false)
    }

    @Test("Builds summaries from budget window, expenses, and fixed costs")
    func buildsSummariesFromModels() throws {
        let calendar = Calendar(identifier: .gregorian)
        let periodDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 20)))
        let period = BudgetPeriod(calendar: calendar, date: periodDate)
        let includedExpenseDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 10)))
        let excludedExpenseDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)))
        let window = BudgetWindow(windowID: "test-window", monthlyBudgetCents: 500_000)

        let summary = BudgetEngine.summary(
            window: window,
            expenses: [
                Expense(budgetWindowID: "test-window", name: "Groceries", amountCents: 10_000, date: includedExpenseDate),
                Expense(budgetWindowID: "test-window", name: "Next month", amountCents: 999_999, date: excludedExpenseDate),
                Expense(budgetWindowID: "other-window", name: "Other", amountCents: 999_999, date: includedExpenseDate)
            ],
            fixedCosts: [
                FixedCost(budgetWindowID: "test-window", name: "Mortgage", amountCents: 200_000),
                FixedCost(budgetWindowID: "test-window", name: "Disabled", amountCents: 999_999, isEnabled: false),
                FixedCost(budgetWindowID: "other-window", name: "Other", amountCents: 999_999)
            ],
            period: period
        )

        #expect(summary.monthKey == "2026-06")
        #expect(summary.fixedCostCents == 200_000)
        #expect(summary.manualExpenseCents == 10_000)
        #expect(summary.usedCents == 210_000)
        #expect(summary.remainingCents == 290_000)
    }

    @Test("Migrates original SwiftData store to current schema")
    func migratesOriginalStoreToBudgetWindowSchema() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension("store")

        do {
            let v1Schema = Schema(versionedSchema: BudgetDataSchemaV1.self)
            let v1Configuration = ModelConfiguration(schema: v1Schema, url: storeURL)
            let v1Container = try ModelContainer(for: v1Schema, configurations: [v1Configuration])
            let context = v1Container.mainContext

            context.insert(BudgetDataSchemaV1.BudgetSettings(monthlyBudgetCents: 123_456))
            context.insert(BudgetDataSchemaV1.Expense(name: "Groceries", amountCents: 2_310))
            context.insert(BudgetDataSchemaV1.FixedCost(name: "Mortgage", amountCents: 100_000))
            try context.save()
        }

        let currentSchema = Schema(versionedSchema: BudgetDataSchemaV3.self)
        let currentConfiguration = ModelConfiguration(schema: currentSchema, url: storeURL)
        let currentContainer = try ModelContainer(
            for: currentSchema,
            migrationPlan: BudgetDataMigrationPlan.self,
            configurations: [currentConfiguration]
        )
        let context = currentContainer.mainContext

        let settings = try context.fetch(FetchDescriptor<BudgetSettings>())
        let expenses = try context.fetch(FetchDescriptor<Expense>())
        let fixedCosts = try context.fetch(FetchDescriptor<FixedCost>())

        #expect(settings.first?.monthlyBudgetCents == 123_456)
        #expect(expenses.first?.name == "Groceries")
        #expect(expenses.first?.amountCents == 2_310)
        #expect(expenses.first?.budgetWindowID == BudgetWindow.defaultWindowID)
        #expect(expenses.first?.categoryName == "")
        #expect(expenses.first?.importIdentifier == "")
        #expect(fixedCosts.first?.name == "Mortgage")
        #expect(fixedCosts.first?.amountCents == 100_000)
        #expect(fixedCosts.first?.budgetWindowID == BudgetWindow.defaultWindowID)

        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
        try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
    }

    @Test("Parses Apple Card CSV transactions")
    func parsesAppleCardCSVTransactions() throws {
        let csv = """
        Transaction Date,Clearing Date,Description,Merchant,Category,Type,Amount (USD),Purchased By
        06/20/2026,06/21/2026,"WEGMANSYARDLEY 925 VANSANT DR YARDLEY 19067 PA USA","Wegmansyardley","Grocery","Purchase","68.63","Cameron Baffuto"
        06/19/2026,06/20/2026,"CAFE ""TEST"" 123 MAIN ST","Cafe Test","Restaurants","Purchase","12.30","Cameron Baffuto"
        """

        let transactions = try AppleCardCSVImporter.transactions(fromCSVText: csv)
        let first = try #require(transactions.first)

        #expect(transactions.count == 2)
        #expect(first.merchant == "Wegmansyardley")
        #expect(first.category == "Grocery")
        #expect(first.type == "Purchase")
        #expect(first.amountCents == 6_863)
        #expect(first.isExpensePurchase)
        #expect(first.importIdentifier.contains(AppleCardTransaction.importSource))
    }

    @Test("Supports custom budget cycle start days")
    func supportsCustomBudgetCycleStartDays() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 10)))
        let period = BudgetPeriod(calendar: calendar, date: date, startDay: 15)
        let included = try #require(calendar.date(from: DateComponents(year: 2026, month: 5, day: 20)))
        let excluded = try #require(calendar.date(from: DateComponents(year: 2026, month: 5, day: 14)))

        #expect(period.monthKey == "2026-05")
        #expect(period.contains(included))
        #expect(!period.contains(excluded))
    }

    @Test("Allows over-budget state")
    func allowsOverBudgetState() {
        let summary = BudgetCalculator.summary(
            budgetCents: 100_000,
            fixedCostCents: 75_000,
            manualExpenseCents: 50_000,
            monthLabel: "June 2026"
        )

        #expect(summary.usedCents == 125_000)
        #expect(summary.remainingCents == -25_000)
        #expect(summary.percentUsed == 1.25)
        #expect(summary.displayProgress == 1)
        #expect(summary.isOverBudget)
    }

    @Test("Classifies usage color thresholds")
    func classifiesUsageColorThresholds() {
        #expect(BudgetUsageLevel(percentUsed: 0.85) == .green)
        #expect(BudgetUsageLevel(percentUsed: 0.86) == .yellow)
        #expect(BudgetUsageLevel(percentUsed: 0.98) == .yellow)
        #expect(BudgetUsageLevel(percentUsed: 0.99) == .red)
        #expect(BudgetUsageLevel(percentUsed: 1.25) == .red)
    }

    @Test("Preserves cents when formatting money")
    func preservesCentsWhenFormattingMoney() throws {
        let cents = try #require(CurrencyFormatter.cents(from: "23.10"))

        #expect(cents == 2_310)
        #expect(CurrencyFormatter.decimalText(for: cents) == "23.10")
        #expect(CurrencyFormatter.dollarsText(for: cents).contains("23.10"))
    }

    @Test("Detects current calendar month dates")
    func detectsCurrentCalendarMonthDates() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 20)))
        let window = MonthWindow.current(calendar: calendar, date: date)

        let included = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 1)))
        let excluded = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)))

        #expect(window.label == "June 2026")
        #expect(window.monthKey == "2026-06")
        #expect(window.contains(included))
        #expect(!window.contains(excluded))
    }
}
