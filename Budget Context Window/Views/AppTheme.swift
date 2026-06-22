import SwiftUI
import UIKit

enum AppTheme {
    static let accent = Color.accentColor
    static let deepTeal = Color(red: 0.0, green: 0.486, blue: 0.451)
    static let warning = Color(red: 0.78, green: 0.55, blue: 0.08)
    static let danger = Color.red
    static let dashboardBackground = adaptiveColor(
        light: UIColor(red: 0.925, green: 0.960, blue: 0.932, alpha: 1),
        dark: UIColor(red: 0.035, green: 0.055, blue: 0.060, alpha: 1)
    )
    static let dashboardSurface = adaptiveColor(
        light: UIColor(red: 0.984, green: 0.992, blue: 0.978, alpha: 1),
        dark: UIColor(red: 0.075, green: 0.100, blue: 0.105, alpha: 1)
    )
    static let elevatedSurface = adaptiveColor(
        light: UIColor(red: 1.000, green: 1.000, blue: 0.992, alpha: 1),
        dark: UIColor(red: 0.095, green: 0.125, blue: 0.130, alpha: 1)
    )
    static let primaryText = adaptiveColor(
        light: UIColor(red: 0.045, green: 0.080, blue: 0.075, alpha: 1),
        dark: .white
    )
    static let mutedText = adaptiveColor(
        light: UIColor(red: 0.310, green: 0.405, blue: 0.380, alpha: 1),
        dark: UIColor(white: 1, alpha: 0.64)
    )
    static let subtleStroke = adaptiveColor(
        light: UIColor(red: 0.000, green: 0.300, blue: 0.275, alpha: 0.12),
        dark: UIColor(white: 1, alpha: 0.08)
    )
    static let ringTrack = adaptiveColor(
        light: UIColor(red: 0.000, green: 0.300, blue: 0.275, alpha: 0.12),
        dark: UIColor(white: 1, alpha: 0.12)
    )
    static let chipFill = adaptiveColor(
        light: UIColor(red: 0.000, green: 0.486, blue: 0.451, alpha: 0.09),
        dark: UIColor(white: 1, alpha: 0.07)
    )
    static let chipStroke = adaptiveColor(
        light: UIColor(red: 0.000, green: 0.300, blue: 0.275, alpha: 0.12),
        dark: UIColor(white: 1, alpha: 0.08)
    )
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

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
