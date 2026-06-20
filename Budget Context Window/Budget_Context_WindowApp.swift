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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            BudgetSettings.self,
            Expense.self,
            FixedCost.self,
            BudgetMonthSnapshot.self
        ])
    }
}
