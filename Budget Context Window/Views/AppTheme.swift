import SwiftUI

enum AppTheme {
    static let accent = Color.accentColor
    static let warning = Color(red: 0.78, green: 0.55, blue: 0.08)
    static let danger = Color.red

    static func color(for usageLevel: BudgetUsageLevel) -> Color {
        switch usageLevel {
        case .green:
            accent
        case .yellow:
            warning
        case .red:
            danger
        }
    }
}
