import Foundation
import SwiftData

@Model
final class ExpenseCategory {
    var budgetWindowID: String = BudgetWindow.defaultWindowID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    init(
        budgetWindowID: String = BudgetWindow.defaultWindowID,
        name: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.budgetWindowID = budgetWindowID
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
