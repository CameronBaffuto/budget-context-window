import SwiftUI

struct MonthHistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let snapshot: BudgetMonthSnapshot

    private var percentText: String {
        snapshot.percentUsed.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 18) {
                        BudgetProgressRingView(
                            percentUsed: snapshot.percentUsed,
                            percentText: percentText,
                            size: 210,
                            lineWidth: 20,
                            textSize: 56
                        )

                        VStack(spacing: 6) {
                            Text(snapshot.monthLabel)
                                .font(.headline)

                            Text("\(CurrencyFormatter.dollarsText(for: snapshot.remainingCents)) remaining")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(snapshot.remainingCents < 0 ? .red : .primary)

                            Text("\(CurrencyFormatter.dollarsText(for: snapshot.usedCents)) used of \(CurrencyFormatter.dollarsText(for: snapshot.budgetCents))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breakdown")
                            .font(.headline)

                        LabeledContent("Fixed costs", value: CurrencyFormatter.dollarsText(for: snapshot.fixedCostCents))
                        LabeledContent("Manual expenses", value: CurrencyFormatter.dollarsText(for: snapshot.manualExpenseCents))
                        LabeledContent("Total used", value: CurrencyFormatter.dollarsText(for: snapshot.usedCents))
                        LabeledContent("Budget", value: CurrencyFormatter.dollarsText(for: snapshot.budgetCents))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))

                    Text("Updated \(snapshot.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(snapshot.monthLabel)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
