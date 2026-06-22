import SwiftData
import SwiftUI

struct FixedCostSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]

    @State private var selectedFixedCost: FixedCost?
    @State private var isAddingFixedCost = false

    private var activeWindowID: String {
        BudgetWindowStore.activeWindowID(from: budgetWindows)
    }

    private var fixedCostsForActiveWindow: [FixedCost] {
        BudgetEngine.fixedCosts(fixedCosts, windowID: activeWindowID)
    }

    var body: some View {
        List {
            if fixedCostsForActiveWindow.isEmpty {
                ContentUnavailableView(
                    "No Fixed Costs",
                    systemImage: "calendar",
                    description: Text("Add recurring costs that should count every month.")
                )
            } else {
                ForEach(fixedCostsForActiveWindow) { fixedCost in
                    HStack {
                        Button {
                            selectedFixedCost = fixedCost
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(fixedCost.name)
                                        .foregroundStyle(.primary)

                                    Image(systemName: fixedCost.isEnabled ? "checkmark.circle.fill" : "circle")
                                        .font(.caption)
                                        .foregroundStyle(fixedCost.isEnabled ? AppTheme.accent : .secondary)
                                }

                                HStack(spacing: 8) {
                                    Text(CurrencyFormatter.dollarsText(for: fixedCost.amountCents))

                                    if !fixedCost.categoryName.isEmpty {
                                        Text(fixedCost.categoryName)
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Menu {
                            Button {
                                selectedFixedCost = fixedCost
                            } label: {
                                ThemedMenuActionLabel(
                                    title: "Edit",
                                    systemImage: "pencil",
                                    color: AppTheme.accent
                                )
                            }
                            .tint(AppTheme.accent)

                            Button {
                                toggleFixedCost(fixedCost)
                            } label: {
                                ThemedMenuActionLabel(
                                    title: fixedCost.isEnabled ? "Disable" : "Enable",
                                    systemImage: fixedCost.isEnabled ? "pause.circle" : "checkmark.circle",
                                    color: AppTheme.accent
                                )
                            }
                            .tint(AppTheme.accent)

                            Button(role: .destructive) {
                                deleteFixedCost(fixedCost)
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
                        .accessibilityLabel("Fixed cost actions for \(fixedCost.name)")
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            deleteFixedCost(fixedCost)
                        }

                        Button(fixedCost.isEnabled ? "Disable" : "Enable", systemImage: fixedCost.isEnabled ? "pause.circle" : "checkmark.circle") {
                            toggleFixedCost(fixedCost)
                        }
                        .tint(AppTheme.accent)
                    }
                }
            }
        }
        .navigationTitle("Fixed Costs")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Fixed Cost", systemImage: "plus") {
                    isAddingFixedCost = true
                }
            }
        }
        .sheet(isPresented: $isAddingFixedCost) {
            FixedCostEditorView(budgetWindowID: activeWindowID)
        }
        .sheet(item: $selectedFixedCost) { fixedCost in
            FixedCostEditorView(fixedCost: fixedCost)
        }
    }

    private func toggleFixedCost(_ fixedCost: FixedCost) {
        fixedCost.isEnabled.toggle()
        try? modelContext.save()
    }

    private func deleteFixedCost(_ fixedCost: FixedCost) {
        modelContext.delete(fixedCost)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        FixedCostSettingsView()
    }
    .modelContainer(for: [BudgetWindow.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
