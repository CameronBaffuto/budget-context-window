import SwiftUI

extension View {
    func themedSurface(padding: CGFloat = 16) -> some View {
        modifier(ThemedSurfaceModifier(padding: padding))
    }
}
