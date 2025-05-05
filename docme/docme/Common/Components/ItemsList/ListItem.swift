import Foundation
import SwiftUI


struct ListItem: View {
    @Environment(\.theme) var theme
    
    enum TrailingView {
        case empty
        case chevron
    }
    
    let title: String
    let trailingText: String?
    let trailingView: TrailingView?
    let onTapAction: (() -> Void)?
    
    init(
        title: String,
        trailingText: String? = nil,
        trailingView: TrailingView? = nil,
        onTapAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.trailingText = trailingText
        self.trailingView = trailingView
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        HStack {
            Text(title)
                .applyFont(.body(.sm, .bold))
                .foregroundStyle(theme.colors.text)
            
            Spacer()
            
            HStack(spacing: DS.Spacing.m6) {
                trailingTextContent
                
                trailingViewContent
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var trailingViewContent: some View {
        if let trailingView {
            switch trailingView {
            case .empty: EmptyView()
            case .chevron: ImageIcon(name: .chevronRightOutline, size: .sm)
            }
        }
    }
    
    @ViewBuilder
    private var trailingTextContent: some View {
        if let trailingText = trailingText {
            Text(trailingText)
                .applyFont(.body(.sm, .regular))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

#Preview {
    VStack {
        ListItem(title: "123", trailingText: "123", trailingView: .chevron)
        ListItem(title: "123", trailingText: "123", trailingView: .empty)
        ListItem(title: "123", trailingView: .chevron)
    }
}
