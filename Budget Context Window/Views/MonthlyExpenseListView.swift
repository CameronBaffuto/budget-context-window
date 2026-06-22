import SwiftUI

struct MonthlyExpenseListView: View {
    let expenses: [Expense]
    let onEdit: (Expense) -> Void
    let onDelete: (Expense) -> Void

    @State private var isExpanded: Bool

    init(
        expenses: [Expense],
        isExpanded: Bool = true,
        onEdit: @escaping (Expense) -> Void,
        onDelete: @escaping (Expense) -> Void
    ) {
        self.expenses = expenses
        self.onEdit = onEdit
        self.onDelete = onDelete
        _isExpanded = State(initialValue: isExpanded)
    }

    private var totalCents: Int {
        expenses.reduce(0) { $0 + $1.amountCents }
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
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

                                HStack(spacing: 8) {
                                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))

                                    if !expense.categoryName.isEmpty {
                                        Text(expense.categoryName)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(AppTheme.chipFill, in: Capsule())
                                    }

                                    if expense.importSource == AppleCardTransaction.importSource {
                                        Image(systemName: "creditcard")
                                            .accessibilityLabel("Imported from Apple Card")
                                    }
                                }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(CurrencyFormatter.dollarsText(for: expense.amountCents))
                                .font(.body.weight(.semibold))

                            Menu {
                                Button {
                                    onEdit(expense)
                                } label: {
                                    ThemedMenuActionLabel(
                                        title: "Edit",
                                        systemImage: "pencil",
                                        color: .white
                                    )
                                }
                                .tint(.white)

                                Button(role: .destructive) {
                                    onDelete(expense)
                                } label: {
                                    ThemedMenuActionLabel(
                                        title: "Delete",
                                        systemImage: "trash",
                                        color: AppTheme.danger
                                    )
                                }
                                .tint(AppTheme.danger)
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                                    .foregroundStyle(.secondary)
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
            .padding(.top, 12)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Manual Expenses")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("\(expenses.count) this month")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                }

                Spacer()

                Text(CurrencyFormatter.dollarsText(for: totalCents))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .themedSurface()
    }
}
