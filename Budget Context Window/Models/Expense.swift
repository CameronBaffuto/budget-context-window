import Foundation
import SwiftData

@Model
final class Expense {
    var budgetWindowID: String = BudgetWindow.defaultWindowID
    var name: String
    var amountCents: Int
    var date: Date
    var createdAt: Date

    init(
        budgetWindowID: String = BudgetWindow.defaultWindowID,
        name: String,
        amountCents: Int,
        date: Date = .now,
        createdAt: Date = .now
    ) {
        self.budgetWindowID = budgetWindowID
        self.name = name
        self.amountCents = amountCents
        self.date = date
        self.createdAt = createdAt
    }
}
