import SwiftUI

struct BudgetGaugeView: View {
    let summary: BudgetSummary

    private var percentText: String {
        summary.percentUsed.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        VStack(spacing: 18) {
            BudgetProgressRingView(
                percentUsed: summary.percentUsed,
                percentText: percentText,
                size: 230,
                lineWidth: 22,
                textSize: 62
            )

            VStack(spacing: 6) {
                Text(summary.monthLabel)
                    .font(.headline)

                Text("\(CurrencyFormatter.dollarsText(for: summary.remainingCents)) remaining")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(summary.isOverBudget ? .red : .primary)
                    .minimumScaleFactor(0.8)

                Text("\(CurrencyFormatter.dollarsText(for: summary.usedCents)) used of \(CurrencyFormatter.dollarsText(for: summary.budgetCents))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    BudgetGaugeView(
        summary: BudgetCalculator.summary(
            budgetCents: 500_000,
            fixedCostCents: 250_000,
            manualExpenseCents: 75_000,
            monthLabel: "June 2026"
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
