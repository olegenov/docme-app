import Foundation
import SwiftUI


struct TextSectionView: View {
    @Environment(\.theme) var theme
    
    let text: String
    
    var body: some View {
        Group {
            Text(text)
                .applyFont(.body(.sm, .regular))
                .foregroundStyle(theme.colors.text)
                .frame(height: DS.Size.m12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, DS.Spacing.m4)
                .padding(.horizontal, DS.Spacing.m8)
                .background(theme.colors.overlay)
                .cornerRadius(DS.Spacing.m8)
        }
        .applyShadow(theme.shadows.overlayShadow)
    }
}

#Preview {
    TextSectionView(text: "123")
}
