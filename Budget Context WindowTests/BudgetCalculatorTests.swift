import Foundation
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

    @Test("Builds summaries from settings, expenses, and fixed costs")
    func buildsSummariesFromModels() throws {
        let calendar = Calendar(identifier: .gregorian)
        let periodDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 20)))
        let period = BudgetPeriod(calendar: calendar, date: periodDate)
        let includedExpenseDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 6, day: 10)))
        let excludedExpenseDate = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 1)))

        let summary = BudgetEngine.summary(
            settings: BudgetSettings(monthlyBudgetCents: 500_000),
            expenses: [
                Expense(name: "Groceries", amountCents: 10_000, date: includedExpenseDate),
                Expense(name: "Next month", amountCents: 999_999, date: excludedExpenseDate)
            ],
            fixedCosts: [
                FixedCost(name: "Mortgage", amountCents: 200_000),
                FixedCost(name: "Disabled", amountCents: 999_999, isEnabled: false)
            ],
            period: period
        )

        #expect(summary.monthKey == "2026-06")
        #expect(summary.fixedCostCents == 200_000)
        #expect(summary.manualExpenseCents == 10_000)
        #expect(summary.usedCents == 210_000)
        #expect(summary.remainingCents == 290_000)
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
