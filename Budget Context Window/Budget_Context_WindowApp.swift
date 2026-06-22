//
//  Budget_Context_WindowApp.swift
//  Budget Context Window
//
//  Created by Cameron Baffuto on 6/20/26.
//

import SwiftUI
import SwiftData

@main
struct Budget_Context_WindowApp: App {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: BudgetDataSchemaV5.self)
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: BudgetDataMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create Budget Window model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
