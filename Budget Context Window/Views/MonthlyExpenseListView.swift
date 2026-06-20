import SwiftUI

struct MonthlyExpenseListView: View {
    let expenses: [Expense]
    let onEdit: (Expense) -> Void
    let onDelete: (Expense) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manual Expenses")
                .font(.headline)

            if expenses.isEmpty {
                ContentUnavailableView(
                    "No Expenses This Month",
                    systemImage: "receipt",
                    description: Text("Tap Add Expense when a new cost comes in.")
                )
                .frame(minHeight: 140)
            } else {
                ForEach(expenses) { expense in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(expense.name)
                                .font(.body.weight(.medium))

                            Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(CurrencyFormatter.dollarsText(for: expense.amountCents))
                            .font(.body.weight(.semibold))

                        Menu {
                            Button("Edit", systemImage: "pencil") {
                                onEdit(expense)
                            }

                            Button("Delete", systemImage: "trash", role: .destructive) {
                                onDelete(expense)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .imageScale(.large)
                                .frame(width: 34, height: 34)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Expense actions for \(expense.name)")
                    }

                    if expense.id != expenses.last?.id {
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
