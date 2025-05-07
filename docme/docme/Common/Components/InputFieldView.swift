import Foundation
import SwiftUI


struct InputFieldView: View {
    @Environment(\.theme) var theme
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .font(.system(size: DSFontSize.sm.fontSize))
                .foregroundColor(theme.colors.textSecondary)
        )
        .font(.system(size: DSFontSize.sm.fontSize))
        .foregroundStyle(theme.colors.text)
        .padding(.vertical, DS.Spacing.m4)
        .padding(.horizontal, DS.Spacing.m8)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Spacing.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
}

#Preview {
    InputFieldView(placeholder: "123", text: .constant("123"))
}
