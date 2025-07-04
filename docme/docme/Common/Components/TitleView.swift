import Foundation
import SwiftUI


struct TitleView: View {
    @Environment(\.theme) var theme
    
    enum Configuration {
        case regular(text: String)
        case editing(text: Binding<String>, placeholder: String)
    }
    
    var configuration: Configuration
    
    init(text: String) {
        configuration = .regular(text: text)
    }
    
    init(editing text: Binding<String>, placeholder: String) {
        configuration = .editing(
            text: text,
            placeholder: placeholder
        )
    }
    
    var body: some View {
        Group {
            switch configuration {
            case .regular(let text): defaultView(text: text)
            case .editing(let text, let placeholder):
                editingView(text: text, placeholder: placeholder)
            }
        }.foregroundStyle(theme.colors.text)
    }
    
    private func defaultView(text: String) -> some View {
        Text(text)
            .applyFont(.body(.lg, .bold))
    }
    
    private func editingView(text: Binding<String>, placeholder: String) -> some View {
        TextField(
            "",
            text: text,
            prompt: Text(placeholder)
                .font(.system(size: DSFontSize.lg.fontSize))
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textSecondary)
        )
        .font(.system(size: DSFontSize.lg.fontSize))
        .fontWeight(.bold)
    }
}

#Preview {
    TitleView(text: "Hello World")
}
