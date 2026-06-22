import SwiftUI

struct BudgetGaugeView: View {
    let summary: BudgetSummary

    private var percentText: String {
        summary.percentUsed.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.monthLabel)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)

                    Text(statusText)
                        .font(.caption.bold())
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.15), in: Capsule())
                }

                Spacer()

                Text(percentText)
                    .font(.title3.bold())
                    .monospacedDigit()
                    .foregroundStyle(statusColor)
            }

            BudgetProgressRingView(
                percentUsed: summary.percentUsed,
                percentText: percentText,
                size: 218,
                lineWidth: 20,
                textSize: 60
            )

            HStack(spacing: 10) {
                BudgetMetricTile(
                    title: "Remaining",
                    value: CurrencyFormatter.dollarsText(for: summary.remainingCents),
                    valueColor: summary.isOverBudget ? AppTheme.danger : AppTheme.primaryText
                )

                BudgetMetricTile(
                    title: "Used",
                    value: CurrencyFormatter.dollarsText(for: summary.usedCents),
                    valueColor: AppTheme.primaryText
                )
            }

            Text("\(CurrencyFormatter.dollarsText(for: summary.budgetCents)) monthly budget")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius)
                    .fill(AppTheme.dashboardSurface)

                LinearGradient(
                    colors: [
                        AppTheme.accent.opacity(0.28),
                        AppTheme.dashboardSurface.opacity(0.2),
                        AppTheme.dashboardSurface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius)
                .stroke(AppTheme.accent.opacity(0.24), lineWidth: 1)
        }
    }

    private var statusText: String {
        switch summary.usageLevel {
        case .green:
            "In Control"
        case .yellow:
            "Watch Zone"
        case .red:
            summary.isOverBudget ? "Over Budget" : "Limit Reached"
        }
    }

    private var statusColor: Color {
        AppTheme.color(for: summary.usageLevel)
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
    .background(AppTheme.dashboardBackground)
}
