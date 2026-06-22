import SwiftUI

enum AppTheme {
    static let accent = Color.accentColor
    static let deepTeal = Color(red: 0.0, green: 0.486, blue: 0.451)
    static let warning = Color(red: 0.78, green: 0.55, blue: 0.08)
    static let danger = Color.red
    static let dashboardBackground = Color(red: 0.035, green: 0.055, blue: 0.06)
    static let dashboardSurface = Color(red: 0.075, green: 0.10, blue: 0.105)
    static let elevatedSurface = Color(red: 0.095, green: 0.125, blue: 0.13)
    static let subtleStroke = Color.white.opacity(0.08)
    static let mutedText = Color.white.opacity(0.64)
    static let chipFill = Color.white.opacity(0.07)
    static let chipStroke = Color.white.opacity(0.08)
    static let sectionCornerRadius: CGFloat = 8

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
