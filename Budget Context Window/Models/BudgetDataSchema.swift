import Foundation
import SwiftData

enum BudgetDataSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ]
    }

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

    @Model
    final class Expense {
        var name: String
        var amountCents: Int
        var date: Date
        var createdAt: Date

        init(name: String, amountCents: Int, date: Date = .now, createdAt: Date = .now) {
            self.name = name
            self.amountCents = amountCents
            self.date = date
            self.createdAt = createdAt
        }
    }

    @Model
    final class FixedCost {
        var name: String
        var amountCents: Int
        var isEnabled: Bool
        var createdAt: Date

        init(name: String, amountCents: Int, isEnabled: Bool = true, createdAt: Date = .now) {
            self.name = name
            self.amountCents = amountCents
            self.isEnabled = isEnabled
            self.createdAt = createdAt
        }
    }

    @Model
    final class BudgetMonthSnapshot {
        var monthKey: String = ""
        var monthStart: Date
        var monthLabel: String
        var budgetCents: Int
        var fixedCostCents: Int
        var manualExpenseCents: Int
        var usedCents: Int
        var remainingCents: Int
        var percentUsed: Double
        var updatedAt: Date

        init(
            monthStart: Date,
            monthLabel: String,
            budgetCents: Int,
            fixedCostCents: Int,
            manualExpenseCents: Int,
            usedCents: Int,
            remainingCents: Int,
            percentUsed: Double,
            updatedAt: Date = .now
        ) {
            self.monthStart = monthStart
            self.monthLabel = monthLabel
            self.budgetCents = budgetCents
            self.fixedCostCents = fixedCostCents
            self.manualExpenseCents = manualExpenseCents
            self.usedCents = usedCents
            self.remainingCents = remainingCents
            self.percentUsed = percentUsed
            self.updatedAt = updatedAt
        }
    }
}

enum BudgetDataSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BudgetWindow.self,
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ]
    }

    @Model
    final class BudgetWindow {
        var windowID: String
        var name: String
        var monthlyBudgetCents: Int
        var cycleStartDay: Int
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date

        init(
            windowID: String = "default",
            name: String = "Monthly Budget",
            monthlyBudgetCents: Int = 500_000,
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

    @Model
    final class Expense {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var date: Date
        var createdAt: Date

        init(
            budgetWindowID: String = "default",
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

    @Model
    final class FixedCost {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var isEnabled: Bool
        var createdAt: Date

        init(
            budgetWindowID: String = "default",
            name: String,
            amountCents: Int,
            isEnabled: Bool = true,
            createdAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.name = name
            self.amountCents = amountCents
            self.isEnabled = isEnabled
            self.createdAt = createdAt
        }
    }

    @Model
    final class BudgetMonthSnapshot {
        var budgetWindowID: String = "default"
        var monthKey: String = ""
        var monthStart: Date
        var monthLabel: String
        var budgetCents: Int
        var fixedCostCents: Int
        var manualExpenseCents: Int
        var usedCents: Int
        var remainingCents: Int
        var percentUsed: Double
        var updatedAt: Date

        init(
            budgetWindowID: String = "default",
            monthStart: Date,
            monthLabel: String,
            budgetCents: Int,
            fixedCostCents: Int,
            manualExpenseCents: Int,
            usedCents: Int,
            remainingCents: Int,
            percentUsed: Double,
            updatedAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.monthStart = monthStart
            self.monthLabel = monthLabel
            self.budgetCents = budgetCents
            self.fixedCostCents = fixedCostCents
            self.manualExpenseCents = manualExpenseCents
            self.usedCents = usedCents
            self.remainingCents = remainingCents
            self.percentUsed = percentUsed
            self.updatedAt = updatedAt
        }
    }
}

enum BudgetDataSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BudgetWindow.self,
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ]
    }

    @Model
    final class BudgetWindow {
        var windowID: String
        var name: String
        var monthlyBudgetCents: Int
        var cycleStartDay: Int
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date

        init(
            windowID: String = "default",
            name: String = "Monthly Budget",
            monthlyBudgetCents: Int = 500_000,
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

    @Model
    final class Expense {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var date: Date
        var createdAt: Date
        var categoryName: String = ""
        var importSource: String = ""
        var importIdentifier: String = ""

        init(
            budgetWindowID: String = "default",
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

    @Model
    final class FixedCost {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var isEnabled: Bool
        var createdAt: Date

        init(
            budgetWindowID: String = "default",
            name: String,
            amountCents: Int,
            isEnabled: Bool = true,
            createdAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.name = name
            self.amountCents = amountCents
            self.isEnabled = isEnabled
            self.createdAt = createdAt
        }
    }

    @Model
    final class BudgetMonthSnapshot {
        var budgetWindowID: String = "default"
        var monthKey: String = ""
        var monthStart: Date
        var monthLabel: String
        var budgetCents: Int
        var fixedCostCents: Int
        var manualExpenseCents: Int
        var usedCents: Int
        var remainingCents: Int
        var percentUsed: Double
        var updatedAt: Date

        init(
            budgetWindowID: String = "default",
            monthStart: Date,
            monthLabel: String,
            budgetCents: Int,
            fixedCostCents: Int,
            manualExpenseCents: Int,
            usedCents: Int,
            remainingCents: Int,
            percentUsed: Double,
            updatedAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.monthStart = monthStart
            self.monthLabel = monthLabel
            self.budgetCents = budgetCents
            self.fixedCostCents = fixedCostCents
            self.manualExpenseCents = manualExpenseCents
            self.usedCents = usedCents
            self.remainingCents = remainingCents
            self.percentUsed = percentUsed
            self.updatedAt = updatedAt
        }
    }
}

enum BudgetDataSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(4, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BudgetWindow.self,
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self,
            ExpenseCategory.self
        ]
    }

    @Model
    final class BudgetWindow {
        var windowID: String
        var name: String
        var monthlyBudgetCents: Int
        var cycleStartDay: Int
        var isArchived: Bool
        var createdAt: Date
        var updatedAt: Date

        init(
            windowID: String = "default",
            name: String = "Monthly Budget",
            monthlyBudgetCents: Int = 500_000,
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

    @Model
    final class Expense {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var date: Date
        var createdAt: Date
        var categoryName: String = ""
        var importSource: String = ""
        var importIdentifier: String = ""

        init(
            budgetWindowID: String = "default",
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

    @Model
    final class FixedCost {
        var budgetWindowID: String = "default"
        var name: String
        var amountCents: Int
        var isEnabled: Bool
        var createdAt: Date

        init(
            budgetWindowID: String = "default",
            name: String,
            amountCents: Int,
            isEnabled: Bool = true,
            createdAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.name = name
            self.amountCents = amountCents
            self.isEnabled = isEnabled
            self.createdAt = createdAt
        }
    }

    @Model
    final class BudgetMonthSnapshot {
        var budgetWindowID: String = "default"
        var monthKey: String = ""
        var monthStart: Date
        var monthLabel: String
        var budgetCents: Int
        var fixedCostCents: Int
        var manualExpenseCents: Int
        var usedCents: Int
        var remainingCents: Int
        var percentUsed: Double
        var updatedAt: Date

        init(
            budgetWindowID: String = "default",
            monthStart: Date,
            monthLabel: String,
            budgetCents: Int,
            fixedCostCents: Int,
            manualExpenseCents: Int,
            usedCents: Int,
            remainingCents: Int,
            percentUsed: Double,
            updatedAt: Date = .now
        ) {
            self.budgetWindowID = budgetWindowID
            self.monthStart = monthStart
            self.monthLabel = monthLabel
            self.budgetCents = budgetCents
            self.fixedCostCents = fixedCostCents
            self.manualExpenseCents = manualExpenseCents
            self.usedCents = usedCents
            self.remainingCents = remainingCents
            self.percentUsed = percentUsed
            self.updatedAt = updatedAt
        }
    }

    @Model
    final class ExpenseCategory {
        var budgetWindowID: String = "default"
        var name: String
        var createdAt: Date
        var updatedAt: Date

        init(
            budgetWindowID: String = "default",
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
}

enum BudgetDataSchemaV5: VersionedSchema {
    static var versionIdentifier = Schema.Version(5, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BudgetWindow.self,
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self,
            ExpenseCategory.self
        ]
    }
}

enum BudgetDataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            BudgetDataSchemaV1.self,
            BudgetDataSchemaV2.self,
            BudgetDataSchemaV3.self,
            BudgetDataSchemaV4.self,
            BudgetDataSchemaV5.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: BudgetDataSchemaV1.self,
                toVersion: BudgetDataSchemaV2.self
            ),
            .lightweight(
                fromVersion: BudgetDataSchemaV2.self,
                toVersion: BudgetDataSchemaV3.self
            ),
            .lightweight(
                fromVersion: BudgetDataSchemaV3.self,
                toVersion: BudgetDataSchemaV4.self
            ),
            .lightweight(
                fromVersion: BudgetDataSchemaV4.self,
                toVersion: BudgetDataSchemaV5.self
            )
        ]
    }
}
