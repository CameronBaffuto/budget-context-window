import Foundation
import SwiftData

@Model
final class BudgetWindow {
    static let defaultWindowID = "default"

    var windowID: String
    var name: String
    var monthlyBudgetCents: Int
    var cycleStartDay: Int
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        windowID: String = UUID().uuidString,
        name: String = "Monthly Budget",
        monthlyBudgetCents: Int = BudgetEngine.defaultMonthlyBudgetCents,
        cycleStartDay: Int = 1,
        isArchived: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.windowID = windowID
        self.name = name
        self.monthlyBudgetCents = monthlyBudgetCents
        self.cycleStartDay = max(1, min(cycleStartDay, 28))
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
