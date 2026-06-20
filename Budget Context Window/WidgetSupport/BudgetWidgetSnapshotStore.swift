import Foundation
import WidgetKit

enum BudgetWidgetSnapshotStore {
    static let appGroupID = "group.com.cambaffuto.BudgetContextWindow"

    private enum Key {
        static let budgetCents = "budgetCents"
        static let usedCents = "usedCents"
        static let remainingCents = "remainingCents"
        static let percentUsed = "percentUsed"
        static let monthLabel = "monthLabel"
        static let updatedAt = "updatedAt"
    }

    static func write(_ summary: BudgetSummary) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return
        }

        defaults.set(summary.budgetCents, forKey: Key.budgetCents)
        defaults.set(summary.usedCents, forKey: Key.usedCents)
        defaults.set(summary.remainingCents, forKey: Key.remainingCents)
        defaults.set(summary.percentUsed, forKey: Key.percentUsed)
        defaults.set(summary.monthLabel, forKey: Key.monthLabel)
        defaults.set(Date(), forKey: Key.updatedAt)

        WidgetCenter.shared.reloadAllTimelines()
    }
}
