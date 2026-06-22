import SwiftUI

struct BudgetMetricTile: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.chipFill, in: RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius)
                .stroke(AppTheme.chipStroke, lineWidth: 1)
        }
    }
}
