import SwiftUI

struct AppleCardImportDraft: Identifiable {
    let id = UUID()
    let transactions: [AppleCardTransaction]
    let duplicateIdentifiers: Set<String>

    var importableTransactions: [AppleCardTransaction] {
        transactions.filter { transaction in
            transaction.isExpensePurchase && !duplicateIdentifiers.contains(transaction.importIdentifier)
        }
    }
}

struct AppleCardImportReviewView: View {
    @Environment(\.dismiss) private var dismiss

    let draft: AppleCardImportDraft
    let onImport: ([AppleCardTransaction]) -> Void

    @State private var selectedIdentifiers: Set<String>

    init(draft: AppleCardImportDraft, onImport: @escaping ([AppleCardTransaction]) -> Void) {
        self.draft = draft
        self.onImport = onImport
        _selectedIdentifiers = State(initialValue: Set(draft.importableTransactions.map(\.importIdentifier)))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if draft.importableTransactions.isEmpty {
                        ContentUnavailableView(
                            "No New Purchases",
                            systemImage: "checkmark.circle",
                            description: Text("This file does not contain new CSV purchases.")
                        )
                    } else {
                        ForEach(draft.transactions) { transaction in
                            transactionRow(transaction)
                        }
                    }
                } header: {
                    Text("\(selectedIdentifiers.count) selected")
                }
            }
            .navigationTitle("Review Import")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        onImport(selectedTransactions)
                        dismiss()
                    }
                    .disabled(selectedTransactions.isEmpty)
                }
            }
        }
    }

    private var selectedTransactions: [AppleCardTransaction] {
        draft.transactions.filter { selectedIdentifiers.contains($0.importIdentifier) }
    }

    private func transactionRow(_ transaction: AppleCardTransaction) -> some View {
        let isDuplicate = draft.duplicateIdentifiers.contains(transaction.importIdentifier)
        let canImport = transaction.isExpensePurchase && !isDuplicate
        let isSelected = selectedIdentifiers.contains(transaction.importIdentifier)

        return Button {
            guard canImport else {
                return
            }

            if isSelected {
                selectedIdentifiers.remove(transaction.importIdentifier)
            } else {
                selectedIdentifiers.insert(transaction.importIdentifier)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.accent : .secondary)
                    .imageScale(.large)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(transaction.merchant)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)

                        if isDuplicate {
                            Text("Duplicate")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        } else if !transaction.isExpensePurchase {
                            Text(transaction.type)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 8) {
                        Text(transaction.transactionDate.formatted(date: .abbreviated, time: .omitted))

                        if !transaction.category.isEmpty {
                            Text(transaction.category)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text(CurrencyFormatter.dollarsText(for: transaction.amountCents))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .opacity(canImport ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!canImport)
    }
}
