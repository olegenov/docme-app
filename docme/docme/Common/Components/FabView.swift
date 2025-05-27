import Foundation
import SwiftUI


struct FabView: View {
    @Environment(\.theme) var theme
    
    enum Content {
        case icon(_ icon: ImageIcon)
        case iconText(_ icon: ImageIcon, _ text: String)
        case text(_ text: String)
        case tags(selectedTags: [TagsView.TagColor])
    }
    
    let content: Content
    var background: Color? = nil
    var isSelected: Bool = false
    var longPaddings: Bool = false
    var onTapAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: DS.Spacing.m4) {
            switch content {
            case .icon(let icon):
                icon
            case .iconText(let icon, let text):
                icon
                textView(text)
            case .text(let text):
                textView(text)
                    .frame(height: DS.Size.m12)
            case .tags(let selectedTags):
                tagsView(selectedTags: selectedTags)
            }
        }
        .padding(.vertical, DS.Spacing.m4)
        .padding(.horizontal, longPaddings ? DS.Spacing.m2 : 0)
        .padding(.leading, DS.Spacing.m4)
        .padding(.trailing, trailingPadding)
        .background(backgroundColor)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
        .onTapGesture(perform: onTapAction ?? {})
    }
    
    @ViewBuilder
    private func textView(_ text: String) -> some View {
        Text(text)
            .applyFont(.body(.sm, .bold))
            .foregroundStyle(theme.colors.text)
    }
    
    private var trailingPadding: CGFloat {
        switch content {
        case .icon, .tags(_), .text(_):
            return DS.Spacing.m4
        case .iconText:
            return DS.Spacing.m6
        }
    }
    
    private var backgroundColor: Color {
        if let background {
            background
        } else {
            isSelected ? theme.colors.overlaySelection : theme.colors.overlay
        }
    }
    
    @ViewBuilder
    private func tagsView(selectedTags: [TagsView.TagColor]) -> some View {
        if selectedTags.isEmpty {
            TagsView(colors: [.red, .yellow, .green])
        } else {
            TagsView(colors: selectedTags)
        }
    }
}

#Preview {
    VStack {
        FabView(
            content: .icon(.init(
                name: .starOutline,
                size: .md,
                color: .red
            ))
        )
        
        FabView(
            content: .iconText(
                .init(name: .starOutline, size: .md, color: .blue),
                "123"
            )
        )
        
        FabView(
            content: .icon(.init(
                name: .chevronLeftOutline,
                size: .md,
                color: .red
            )),
            longPaddings: true
        )
        
        FabView(
            content: .tags(selectedTags: [])
        )
        
        FabView(
            content: .tags(selectedTags: [.red])
        )
        
        FabView(
            content: .text("123"),
            longPaddings: true
        )
        
        FabView(
            content: .text("123"),
            longPaddings: false
        )
    }
}
