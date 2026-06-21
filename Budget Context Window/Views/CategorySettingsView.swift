import SwiftData
import SwiftUI

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BudgetWindow.createdAt) private var budgetWindows: [BudgetWindow]
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var selectedCategory: ExpenseCategory?
    @State private var isAddingCategory = false

    private var activeWindowID: String {
        BudgetWindowStore.activeWindowID(from: budgetWindows)
    }

    private var categoriesForActiveWindow: [ExpenseCategory] {
        ExpenseCategoryStore.activeCategories(categories, budgetWindowID: activeWindowID)
    }

    var body: some View {
        List {
            if categoriesForActiveWindow.isEmpty {
                ContentUnavailableView(
                    "No Categories",
                    systemImage: "tag",
                    description: Text("Add categories for expenses and fixed costs.")
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
                            Button {
                                selectedCategory = category
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                deleteCategory(category)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .imageScale(.large)
                                .foregroundStyle(.secondary)
                                .frame(width: 34, height: 34)
                                .contentShape(.rect)
                        }
                        .tint(.primary)
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
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Category", systemImage: "plus") {
                    isAddingCategory = true
                }
            }
        }
        .sheet(isPresented: $isAddingCategory) {
            ExpenseCategoryEditorView(budgetWindowID: activeWindowID)
        }
        .sheet(item: $selectedCategory) { category in
            ExpenseCategoryEditorView(category: category)
        }
    }

    private func deleteCategory(_ category: ExpenseCategory) {
        modelContext.delete(category)
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        CategorySettingsView()
    }
    .modelContainer(for: [BudgetWindow.self, Expense.self, FixedCost.self, ExpenseCategory.self], inMemory: true)
}
