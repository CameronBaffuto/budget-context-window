import SwiftUI

struct ThemedSurfaceModifier: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.sectionCornerRadius)
                    .stroke(AppTheme.subtleStroke, lineWidth: 1)
            }
    }
}
