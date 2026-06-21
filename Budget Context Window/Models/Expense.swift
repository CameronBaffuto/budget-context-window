import Foundation
import SwiftData

@Model
final class Expense {
    var budgetWindowID: String = BudgetWindow.defaultWindowID
    var name: String
    var amountCents: Int
    var date: Date
    var createdAt: Date
    var categoryName: String = ""
    var importSource: String = ""
    var importIdentifier: String = ""

    init(
        budgetWindowID: String = BudgetWindow.defaultWindowID,
        name: String,
        amountCents: Int,
        date: Date = .now,
        createdAt: Date = .now,
        categoryName: String = "",
        importSource: String = "",
        importIdentifier: String = ""
    ) {
        self.budgetWindowID = budgetWindowID
        self.name = name
        self.amountCents = amountCents
        self.date = date
        self.createdAt = createdAt
        self.categoryName = categoryName
        self.importSource = importSource
        self.importIdentifier = importIdentifier
    }
}
