import Foundation
import SwiftUI


struct TagsView: View {
    @Environment(\.theme) var theme
    
    enum TagColor {
        case empty
        case red
        case yellow
        case green
    }
    
    let colors: [TagColor]
    
    var body: some View {
        HStack(spacing: -6) {
            ForEach(colors, id: \.self) { color in
                TagView(color: color)
            }
        }
        .frame(width: DS.Size.m12, height: DS.Size.m12)
    }
}

private struct TagView: View {
    @Environment(\.theme) var theme
    
    let color: TagsView.TagColor
    
    var body: some View {
        switch color {
        case .empty: emptyCircle
        case .red, .green, .yellow: coloredCircle
        }
    }
    
    private var emptyCircle: some View {
        Circle()
            .strokeBorder(borderColor, lineWidth: DS.Size.m)
            .frame(width: DS.Size.m6, height: DS.Size.m6)
    }
    
    private var coloredCircle: some View {
        Circle()
            .foregroundStyle(foregroundColor)
            .frame(width: DS.Size.m6, height: DS.Size.m6)
    }
    
    private var foregroundColor: Color {
        switch color {
        case .empty: .clear
        case .red: theme.colors.brandMagenta
        case .green: theme.colors.brandCyan
        case .yellow: theme.colors.brandGreen
        }
    }
    
    private var borderColor: Color {
        switch color {
        case .empty: theme.colors.outline
        case .red, .green, .yellow: .clear
        }
    }
}

#Preview {
    VStack {
        TagsView(colors: [.empty])
        TagsView(colors: [.yellow])
        TagsView(colors: [.red])
        TagsView(colors: [.green])
        TagsView(colors: [.red, .yellow, .green])
    }
}
