import SwiftUI

struct BudgetBreakdownView: View {
    let summary: BudgetSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)
                .foregroundStyle(.white)

            LabeledContent("Fixed costs", value: CurrencyFormatter.dollarsText(for: summary.fixedCostCents))
            LabeledContent("Manual expenses", value: CurrencyFormatter.dollarsText(for: summary.manualExpenseCents))
            LabeledContent("Total used", value: CurrencyFormatter.dollarsText(for: summary.usedCents))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .themedSurface()
    }
}
