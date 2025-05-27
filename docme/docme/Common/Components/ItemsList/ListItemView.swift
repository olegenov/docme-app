import Foundation
import SwiftUI


struct ListItemView: View {
    @Environment(\.theme) var theme
    
    enum Configuration {
        case defaultStyle(
            title: String,
            leadingView: LeadingView
        )
        case editing(
            placeholder: String,
            title: Binding<String>
        )
    }
    
    enum LeadingView {
        case empty
        case icon(ImageIcon)
    }
    
    enum TrailingView {
        case empty
        case chevron
        case cross
        case loading
        case save(action: () -> Void)
        case delete(action: () -> Void)
    }
    
    let configuration: Configuration
    let trailingText: String?
    let trailingView: TrailingView?
    let onTapAction: (() -> Void)?
    let onDeleteAction: (() -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var isDeletionVisible: Bool = false
    
    init(
        configuration: Configuration,
        trailingText: String? = nil,
        trailingView: TrailingView? = nil,
        onTapAction: (() -> Void)? = nil,
        onDeleteAction: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.trailingText = trailingText
        self.trailingView = trailingView
        self.onTapAction = onTapAction
        self.onDeleteAction = onDeleteAction
    }
    
    var body: some View {
        ZStack {
            if onDeleteAction != nil {
                deleteView
            }
            
            content
        }
    }
    
    private var content: some View {
        HStack {
            switch configuration {
            case .defaultStyle(let title, let leadingView):
                defaultContent(
                    title: title,
                    leadingView: leadingView
                )
            case .editing(let placeholder, let title):
                editingContent(
                    placeholder: placeholder,
                    title: title
                )
            }
            
            Spacer()
            
            HStack(spacing: DS.Spacing.m6) {
                trailingTextContent
                
                trailingViewContent
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .applyIf(onTapAction != nil) { view in
            view.onTapGesture(perform: onTapAction ?? { })
        }
        .offset(x: offset)
        .animation(.easeInOut, value: offset)
        .applyIf(onDeleteAction != nil) { view in
            view.gesture(deleteGesture)
        }
    }
    
    private var deleteView: some View {
        ZStack(alignment: .trailing) {
            Color.clear
                .ignoresSafeArea()
            
            if isDeletionVisible {
                ImageIcon(
                    name: .deleteOutline,
                    size: .sm,
                    color: theme.colors.brandMagenta
                )
                .onTapGesture {
                    onDeleteAction?()
                    offset = 0
                }
            }
        }
        .onChange(of: offset) {
            isDeletionVisible = offset < -DS.Spacing.m14
        }
        .animation(.easeInOut, value: isDeletionVisible)
    }
    
    private func defaultContent(
        title: String,
        leadingView: LeadingView
    ) -> some View {
        HStack(spacing: DS.Spacing.m2) {
            leadingViewContent(leadingView)
            
            Text(title)
                .applyFont(.body(.sm, .bold))
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)
        }
    }
    
    private func editingContent(
        placeholder: String,
        title: Binding<String>
    ) -> some View {
        TextField(
            "",
            text: title,
            prompt: Text(placeholder)
                .font(.system(size: DSFontSize.sm.fontSize))
                .foregroundColor(theme.colors.textSecondary)
        )
    }
    
    @ViewBuilder
    private func leadingViewContent(_ leading: LeadingView?) -> some View {
        if let leading {
            switch leading {
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
            case .loading: ActivityIndicatorView(size: .sm)
            case .save(let action):
                ImageIcon(name: .saveOutline, size: .sm)
                    .onTapGesture(perform: action)
            case .delete(let action):
                ImageIcon(name: .crossOutline, size: .sm)
                    .onTapGesture(perform: action)
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
    
    private var deleteGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.width < 0 {
                    offset = gesture.translation.width
                }
            }
            .onEnded { gesture in
                if gesture.translation.width < DS.Spacing.m16 {
                    offset = -DS.Spacing.m16
                } else {
                    offset = 0
                }
            }
    }
}
