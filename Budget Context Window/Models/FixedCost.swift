import Foundation
import SwiftData

@Model
final class FixedCost {
    var budgetWindowID: String = BudgetWindow.defaultWindowID
    var name: String
    var amountCents: Int
    var categoryName: String = ""
    var isEnabled: Bool
    var createdAt: Date

    init(
        budgetWindowID: String = BudgetWindow.defaultWindowID,
        name: String,
        amountCents: Int,
        categoryName: String = "",
        isEnabled: Bool = true,
        createdAt: Date = .now
    ) {
        self.budgetWindowID = budgetWindowID
        self.name = name
        self.amountCents = amountCents
        self.categoryName = categoryName
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}
