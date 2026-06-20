import SwiftUI
import WidgetKit

struct BudgetWidgetSnapshot {
    let budgetCents: Int
    let usedCents: Int
    let remainingCents: Int
    let percentUsed: Double
    let monthLabel: String
    let updatedAt: Date

    var displayProgress: Double {
        min(max(percentUsed, 0), 1)
    }

    var isOverBudget: Bool {
        remainingCents < 0
    }

    var usageLevel: BudgetWidgetUsageLevel {
        BudgetWidgetUsageLevel(percentUsed: percentUsed)
    }

    static let placeholder = BudgetWidgetSnapshot(
        budgetCents: 500_000,
        usedCents: 495_000,
        remainingCents: 5_000,
        percentUsed: 0.99,
        monthLabel: "June 2026",
        updatedAt: .now
    )

    static func current() -> BudgetWidgetSnapshot {
        guard let defaults = UserDefaults(suiteName: "group.com.cambaffuto.BudgetContextWindow") else {
            return .placeholder
        }

        let budgetCents = defaults.integer(forKey: "budgetCents")
        guard budgetCents > 0 else {
            return .placeholder
        }

        return BudgetWidgetSnapshot(
            budgetCents: budgetCents,
            usedCents: defaults.integer(forKey: "usedCents"),
            remainingCents: defaults.integer(forKey: "remainingCents"),
            percentUsed: defaults.double(forKey: "percentUsed"),
            monthLabel: defaults.string(forKey: "monthLabel") ?? "This Month",
            updatedAt: defaults.object(forKey: "updatedAt") as? Date ?? .now
        )
    }
}

struct BudgetWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: BudgetWidgetSnapshot
}

struct BudgetWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BudgetWidgetEntry {
        BudgetWidgetEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (BudgetWidgetEntry) -> Void) {
        completion(BudgetWidgetEntry(date: .now, snapshot: BudgetWidgetSnapshot.current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetWidgetEntry>) -> Void) {
        let entry = BudgetWidgetEntry(date: .now, snapshot: BudgetWidgetSnapshot.current())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct Budget_Context_WindowWidget: Widget {
    private let kind = "Budget_Context_WindowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BudgetWidgetProvider()) { entry in
            BudgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Budget Window")
        .description("Track the current month budget context.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

enum BudgetWidgetUsageLevel {
    case green
    case yellow
    case red

    init(percentUsed: Double) {
        if percentUsed <= 0.85 {
            self = .green
        } else if percentUsed < 0.99 {
            self = .yellow
        } else {
            self = .red
        }
    }
}

struct BudgetWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: BudgetWidgetEntry

    private var percentText: String {
        entry.snapshot.percentUsed.formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            accessoryCircularLayout
                .containerBackground(.clear, for: .widget)
        case .systemMedium:
            mediumLayout
                .containerBackground(.background, for: .widget)
        default:
            smallLayout
                .containerBackground(.background, for: .widget)
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 8) {
            WidgetProgressRingView(
                percentUsed: entry.snapshot.percentUsed,
                percentText: percentText,
                size: 92,
                lineWidth: 8,
                textSize: 24
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(currencyText(for: entry.snapshot.remainingCents))
                    .font(.headline)
                    .foregroundStyle(entry.snapshot.isOverBudget ? .red : .primary)
                    .minimumScaleFactor(0.75)

                Text("remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            WidgetProgressRingView(
                percentUsed: entry.snapshot.percentUsed,
                percentText: percentText,
                size: 96,
                lineWidth: 8,
                textSize: 26
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.snapshot.monthLabel)
                    .font(.headline)

                Text("\(currencyText(for: entry.snapshot.remainingCents)) remaining")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(entry.snapshot.isOverBudget ? .red : .primary)
                    .minimumScaleFactor(0.75)

                Text("\(currencyText(for: entry.snapshot.usedCents)) used of \(currencyText(for: entry.snapshot.budgetCents))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
    }

    private var accessoryCircularLayout: some View {
        WidgetProgressRingView(
            percentUsed: entry.snapshot.percentUsed,
            percentText: percentText,
            size: 56,
            lineWidth: 4,
            textSize: 15
        )
        .widgetAccentable()
    }

    private func currencyText(for cents: Int) -> String {
        (Double(cents) / 100.0)
            .formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0 ... 2)))
    }
}

private struct WidgetProgressRingView: View {
    let percentUsed: Double
    let percentText: String
    let size: CGFloat
    let lineWidth: CGFloat
    let textSize: CGFloat

    private var displayProgress: Double {
        min(max(percentUsed, 0), 1)
    }

    private var ringColor: Color {
        switch BudgetWidgetUsageLevel(percentUsed: percentUsed) {
        case .green:
            .green
        case .yellow:
            .yellow
        case .red:
            .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: displayProgress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text(percentText)
                .font(.system(size: textSize, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .foregroundStyle(ringColor)
                .frame(width: size - (lineWidth * 2.6))
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Budget used")
        .accessibilityValue(percentText)
    }
}

#Preview(as: .systemSmall) {
    Budget_Context_WindowWidget()
} timeline: {
    BudgetWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .systemMedium) {
    Budget_Context_WindowWidget()
} timeline: {
    BudgetWidgetEntry(date: .now, snapshot: .placeholder)
}

#Preview(as: .accessoryCircular) {
    Budget_Context_WindowWidget()
} timeline: {
    BudgetWidgetEntry(date: .now, snapshot: .placeholder)
}
