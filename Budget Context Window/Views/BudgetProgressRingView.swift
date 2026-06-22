import SwiftUI

struct BudgetProgressRingView: View {
    let percentUsed: Double
    let percentText: String
    let size: CGFloat
    let lineWidth: CGFloat
    let textSize: CGFloat

    private var displayProgress: Double {
        min(max(percentUsed, 0), 1)
    }

    private var ringColor: Color {
        AppTheme.color(for: BudgetUsageLevel(percentUsed: percentUsed))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.ringTrack, lineWidth: lineWidth)

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
                .minimumScaleFactor(0.45)
                .foregroundStyle(ringColor)
                .frame(width: size - (lineWidth * 3.2))
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Spendable window used")
        .accessibilityValue(percentText)
    }
}

#Preview {
    VStack(spacing: 24) {
        BudgetProgressRingView(percentUsed: 0.67, percentText: "67%", size: 230, lineWidth: 22, textSize: 62)
        BudgetProgressRingView(percentUsed: 1.25, percentText: "125%", size: 230, lineWidth: 22, textSize: 62)
    }
    .padding()
}
