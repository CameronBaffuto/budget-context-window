import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetSettings.createdAt) private var settings: [BudgetSettings]
    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]
    @Query(sort: \FixedCost.createdAt) private var fixedCosts: [FixedCost]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    private var activeWindow: BudgetWindow? {
        BudgetWindowStore.activeWindow(from: budgetWindows)
    }

    private var activeWindowID: String {
        BudgetWindowStore.activeWindowID(from: budgetWindows)
    }

    private var monthlyBudgetCents: Int {
        activeWindow?.monthlyBudgetCents ?? settings.first?.monthlyBudgetCents ?? BudgetEngine.defaultMonthlyBudgetCents
    }

    private var fixedCostsForActiveWindow: [FixedCost] {
        BudgetEngine.fixedCosts(fixedCosts, windowID: activeWindowID)
    }

    private var categoriesForActiveWindow: [ExpenseCategory] {
        ExpenseCategoryStore.activeCategories(categories, budgetWindowID: activeWindowID)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Budget") {
                    NavigationLink(value: SettingsRoute.monthlyBudget) {
                        SettingsRowView(
                            title: "Monthly Budget",
                            subtitle: CurrencyFormatter.dollarsText(for: monthlyBudgetCents),
                            systemImage: "gauge.with.dots.needle.bottom.50percent"
                        )
                    }
                }

                Section("Spending Setup") {
                    NavigationLink(value: SettingsRoute.fixedCosts) {
                        SettingsRowView(
                            title: "Fixed Costs",
                            subtitle: "\(fixedCostsForActiveWindow.count) items",
                            systemImage: "calendar"
                        )
                    }

                    NavigationLink(value: SettingsRoute.categories) {
                        SettingsRowView(
                            title: "Categories",
                            subtitle: "\(categoriesForActiveWindow.count) items",
                            systemImage: "tag"
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .monthlyBudget:
                    MonthlyBudgetSettingsView()
                case .fixedCosts:
                    FixedCostSettingsView()
                case .categories:
                    CategorySettingsView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                ensureDefaultWindow()
                ensureDefaultCategories()
            }
        }
    }

    private func ensureDefaultWindow() {
        try? BudgetWindowStore.ensureDefaultWindow(
            settings: settings,
            windows: budgetWindows,
            expenses: expenses,
            fixedCosts: fixedCosts,
            snapshots: [],
            modelContext: modelContext
        )
    }

    private func ensureDefaultCategories() {
        try? ExpenseCategoryStore.ensureDefaultsIfNeeded(
            categories: categories,
            expenses: expenses,
            fixedCosts: fixedCosts,
            budgetWindowID: activeWindowID,
            modelContext: modelContext
        )
    }
}

private enum SettingsRoute: Hashable {
    case monthlyBudget
    case fixedCosts
    case categories
}

private struct SettingsRowView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.accent)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
