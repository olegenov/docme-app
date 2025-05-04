import SwiftUI


extension Text {
    func applyFont(_ style: DSTextStyle) -> some View {
        self
            .modifier(DSFontModifier(style: style))
            .lineSpacing(getLineHeight(style))
    }
    
    func getLineHeight(_ style: DSTextStyle) -> CGFloat {
        switch style {
        case .body(let size, _):
            return size.lineHeight
        }
    }
}

struct DSFontModifier: ViewModifier {
    let style: DSTextStyle

    func body(content: Content) -> some View {
        switch style {
        case .body(let size, let weight):
            content.font(fontForBody(size: size, weight: weight))
        }
    }

    private func fontForBody(size: DSFontSize, weight: DSFontWeight) -> Font {
        let fontWeight: Font.Weight

        switch weight {
        case .regular: fontWeight = .regular
        case .bold: fontWeight = .semibold
        }

        return .system(size: size.fontSize, weight: fontWeight)
    }
}
