import Foundation
import SwiftData

@Model
final class BudgetSettings {
    var monthlyBudgetCents: Int
    var createdAt: Date
    var updatedAt: Date

    init(monthlyBudgetCents: Int = 500_000, createdAt: Date = .now, updatedAt: Date = .now) {
        self.monthlyBudgetCents = monthlyBudgetCents
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
