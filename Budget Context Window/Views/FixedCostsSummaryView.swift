import SwiftUI

struct FixedCostsSummaryView: View {
    let fixedCosts: [FixedCost]

    private var enabledFixedCosts: [FixedCost] {
        fixedCosts.filter(\.isEnabled)
    }

    private var enabledTotal: Int {
        enabledFixedCosts.reduce(0) { $0 + $1.amountCents }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fixed Costs")
                    .font(.headline)

                Spacer()

                Text(CurrencyFormatter.dollarsText(for: enabledTotal))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if enabledFixedCosts.isEmpty {
                ContentUnavailableView(
                    "No Fixed Costs",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Add mortgage, car payment, or other recurring costs in Settings.")
                )
                .frame(minHeight: 120)
            } else {
                ForEach(enabledFixedCosts) { fixedCost in
                    HStack {
                        Text(fixedCost.name)
                        Spacer()
                        Text(CurrencyFormatter.dollarsText(for: fixedCost.amountCents))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)

                    if fixedCost.id != enabledFixedCosts.last?.id {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}
