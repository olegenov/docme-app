import Foundation
import SwiftUI


struct ListItem: View {
    @Environment(\.theme) var theme
    
    enum LeadingView {
        case empty
        case icon(ImageIcon)
    }
    
    enum TrailingView {
        case empty
        case chevron
        case cross
        case loading
    }
    
    let title: String
    let trailingText: String?
    let leadingView: LeadingView?
    let trailingView: TrailingView?
    let onTapAction: (() -> Void)?
    
    init(
        title: String,
        trailingText: String? = nil,
        leadingView: LeadingView? = nil,
        trailingView: TrailingView? = nil,
        onTapAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.trailingText = trailingText
        self.leadingView = leadingView
        self.trailingView = trailingView
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        HStack {
            HStack(spacing: DS.Spacing.m2) {
                leadingViewContent
                
                Text(title)
                    .applyFont(.body(.sm, .bold))
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: DS.Spacing.m6) {
                trailingTextContent
                
                trailingViewContent
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture(perform: onTapAction ?? { })
    }
    
    @ViewBuilder
    private var leadingViewContent: some View {
        if let leadingView {
            switch leadingView {
            case .empty: EmptyView()
            case .icon(let icon): icon
            }
        }
    }
    
    @ViewBuilder
    private var trailingViewContent: some View {
        if let trailingView {
            switch trailingView {
            case .empty: EmptyView()
            case .chevron: ImageIcon(name: .chevronRightOutline, size: .sm)
            case .cross: ImageIcon(name: .crossOutline, size: .sm)
            case .loading: ActivityIndicator(size: .sm)
            }
        }
    }
    
    @ViewBuilder
    private var trailingTextContent: some View {
        if let trailingText = trailingText {
            Text(trailingText)
                .applyFont(.body(.sm, .regular))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    VStack {
        ListItem(title: "123", trailingText: "123", trailingView: .chevron)
        ListItem(title: "123", trailingText: "123", trailingView: .empty)
        ListItem(title: "123", trailingView: .chevron)
        ListItem(title: "123", trailingView: .cross)
        ListItem(title: "123", trailingView: .loading)
        ListItem(title: "123", leadingView: .icon(.init(name: .starOutline, size: .md)))
    }
}
