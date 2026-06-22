import SwiftUI

struct FixedCostsSummaryView: View {
    let fixedCosts: [FixedCost]

    @State private var isExpanded: Bool

    init(fixedCosts: [FixedCost], isExpanded: Bool = false) {
        self.fixedCosts = fixedCosts
        _isExpanded = State(initialValue: isExpanded)
    }

    private var enabledFixedCosts: [FixedCost] {
        fixedCosts.filter(\.isEnabled)
    }

    private var enabledTotal: Int {
        enabledFixedCosts.reduce(0) { $0 + $1.amountCents }
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
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
                            VStack(alignment: .leading, spacing: 3) {
                                Text(fixedCost.name)

                                if !fixedCost.categoryName.isEmpty {
                                    Text(fixedCost.categoryName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

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
            .padding(.top, 12)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Fixed Costs")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(enabledFixedCosts.count) recurring")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                }

                Spacer()

                Text(CurrencyFormatter.dollarsText(for: enabledTotal))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .themedSurface()
    }
}
