import SwiftUI

struct MonthHistoryListView: View {
    let snapshots: [BudgetMonthSnapshot]
    let onSelect: (BudgetMonthSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly History")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText)

            if snapshots.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("This month will appear here after your budget summary is saved.")
                )
                .frame(minHeight: 120)
            } else {
                ForEach(snapshots) { snapshot in
                    Button {
                        onSelect(snapshot)
                    } label: {
                        HStack(spacing: 12) {
                            BudgetProgressRingView(
                                percentUsed: snapshot.percentUsed,
                                percentText: snapshot.percentUsed.formatted(.percent.precision(.fractionLength(0))),
                                size: 52,
                                lineWidth: 5,
                                textSize: 14
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(snapshot.monthLabel)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(AppTheme.primaryText)

                                Text("\(CurrencyFormatter.dollarsText(for: snapshot.usedCents)) manual used")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedText)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(snapshot.percentUsed.formatted(.percent.precision(.fractionLength(0))))
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.color(for: snapshot.usageLevel))

                                Text(CurrencyFormatter.dollarsText(for: snapshot.remainingCents))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedText)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.mutedText)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)

                    if snapshot.id != snapshots.last?.id {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedSurface()
    }

}
