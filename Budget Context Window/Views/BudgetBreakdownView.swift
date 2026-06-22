import SwiftUI

struct BudgetBreakdownView: View {
    let summary: BudgetSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            LabeledContent("Monthly budget", value: CurrencyFormatter.dollarsText(for: summary.budgetCents))
            LabeledContent("Fixed costs reserved", value: CurrencyFormatter.dollarsText(for: summary.fixedCostCents))
            LabeledContent("Spendable window", value: CurrencyFormatter.dollarsText(for: summary.spendableBudgetCents))
            LabeledContent("Manual expenses", value: CurrencyFormatter.dollarsText(for: summary.manualExpenseCents))
            LabeledContent("Total committed", value: CurrencyFormatter.dollarsText(for: summary.totalCommittedCents))
            LabeledContent("Full budget used", value: summary.totalBudgetPercentUsed.formatted(.percent.precision(.fractionLength(0))))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(AppTheme.primaryText)
        .themedSurface()
    }
}
