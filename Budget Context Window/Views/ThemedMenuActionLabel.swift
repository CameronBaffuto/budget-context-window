import SwiftUI

struct ThemedMenuActionLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: systemImage)
                .symbolRenderingMode(.monochrome)
        }
        .foregroundStyle(color)
    }
}
