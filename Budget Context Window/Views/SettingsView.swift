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

    @State private var budgetText = ""
    @State private var selectedFixedCost: FixedCost?
    @State private var selectedCategory: ExpenseCategory?
    @State private var isAddingFixedCost = false
    @State private var isAddingCategory = false
    @State private var showsValidationError = false

    private var activeWindow: BudgetWindow? {
        BudgetWindowStore.activeWindow(from: budgetWindows)
    }

    private var activeWindowID: String {
        BudgetWindowStore.activeWindowID(from: budgetWindows)
    }

    private var fixedCostsForActiveWindow: [FixedCost] {
        BudgetEngine.fixedCosts(fixedCosts, windowID: activeWindowID)
    }

    private var categoriesForActiveWindow: [ExpenseCategory] {
        ExpenseCategoryStore.activeCategories(categories, budgetWindowID: activeWindowID)
    }

    private var monthlyBudgetCents: Int {
        activeWindow?.monthlyBudgetCents ?? settings.first?.monthlyBudgetCents ?? BudgetEngine.defaultMonthlyBudgetCents
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Monthly Budget") {
                    TextField("Budget", text: $budgetText)
                        .keyboardType(.decimalPad)
                }

                Section("Fixed Costs") {
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
                                                .foregroundStyle(fixedCost.isEnabled ? .green : .secondary)
                                        }

                                        Text(CurrencyFormatter.dollarsText(for: fixedCost.amountCents))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                Menu {
                                    Button("Edit", systemImage: "pencil") {
                                        selectedFixedCost = fixedCost
                                    }

                                    Button(fixedCost.isEnabled ? "Disable" : "Enable", systemImage: fixedCost.isEnabled ? "pause.circle" : "checkmark.circle") {
                                        toggleFixedCost(fixedCost)
                                    }

                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        deleteFixedCost(fixedCost)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.large)
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
                                .tint(.blue)
                            }
                        }
                    }

                    Button("Add Fixed Cost", systemImage: "plus") {
                        isAddingFixedCost = true
                    }
                }

                Section("Categories") {
                    if categoriesForActiveWindow.isEmpty {
                        ContentUnavailableView(
                            "No Categories",
                            systemImage: "tag",
                            description: Text("Add categories for manual expenses.")
                        )
                    } else {
                        ForEach(categoriesForActiveWindow) { category in
                            HStack {
                                Button {
                                    selectedCategory = category
                                } label: {
                                    Text(category.name)
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)

                                Spacer()

                                Menu {
                                    Button("Edit", systemImage: "pencil") {
                                        selectedCategory = category
                                    }

                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        deleteCategory(category)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .imageScale(.large)
                                        .frame(width: 34, height: 34)
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Category actions for \(category.name)")
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    deleteCategory(category)
                                }
                            }
                        }
                    }

                    Button("Add Category", systemImage: "plus") {
                        isAddingCategory = true
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        saveBudget()
                    }
                }
            }
            .onAppear {
                ensureDefaultWindow()
                ensureDefaultCategories()
                budgetText = CurrencyFormatter.decimalText(for: monthlyBudgetCents)
            }
            .sheet(isPresented: $isAddingFixedCost) {
                FixedCostEditorView(budgetWindowID: activeWindowID)
            }
            .sheet(isPresented: $isAddingCategory) {
                ExpenseCategoryEditorView(budgetWindowID: activeWindowID)
            }
            .sheet(item: $selectedFixedCost) { fixedCost in
                FixedCostEditorView(fixedCost: fixedCost)
            }
            .sheet(item: $selectedCategory) { category in
                ExpenseCategoryEditorView(category: category)
            }
            .alert("Check Budget", isPresented: $showsValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Enter a monthly budget greater than zero.")
            }
        }
    }

    private func saveBudget() {
        guard let budgetCents = CurrencyFormatter.cents(from: budgetText), budgetCents > 0 else {
            showsValidationError = true
            return
        }

        let budgetSettings = settings.first ?? BudgetSettings()
        budgetSettings.monthlyBudgetCents = budgetCents
        budgetSettings.updatedAt = .now

        if settings.isEmpty {
            modelContext.insert(budgetSettings)
        }

        let budgetWindow = activeWindow ?? BudgetWindow(windowID: BudgetWindow.defaultWindowID)
        budgetWindow.monthlyBudgetCents = budgetCents
        budgetWindow.updatedAt = .now

        if activeWindow == nil {
            modelContext.insert(budgetWindow)
        }

        try? modelContext.save()
        dismiss()
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
            budgetWindowID: activeWindowID,
            modelContext: modelContext
        )
    }

    private func toggleFixedCost(_ fixedCost: FixedCost) {
        fixedCost.isEnabled.toggle()
        try? modelContext.save()
    }

    private func deleteFixedCost(_ fixedCost: FixedCost) {
        modelContext.delete(fixedCost)
        try? modelContext.save()
    }

    private func deleteCategory(_ category: ExpenseCategory) {
        modelContext.delete(category)
        try? modelContext.save()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BudgetWindow.self, BudgetSettings.self, Expense.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
