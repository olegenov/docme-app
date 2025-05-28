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
        case fullEditing(
            placeholder: String,
            title: Binding<String>,
            placeholderSecondary: String,
            secondary: Binding<String>
        )
    }
    
    enum LeadingView {
        case empty
        case icon(ImageIcon)
    }
    
    enum TrailingView {
        case empty
        case chevron
        case cross(action: () -> Void)
        case loading
        case save(action: () -> Void)
        case delete(action: () -> Void)
        case copy(action: () -> Void)
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
                
                Spacer()
                
                readonlyTrailing
            case .editing(let placeholder, let title):
                editingContent(
                    placeholder: placeholder,
                    title: title
                )
                
                Spacer()
                
                readonlyTrailing
            case .fullEditing(
                let placeholder,
                let title,
                let placeholderSecondary,
                let secondary
            ):
                editingContent(
                    placeholder: placeholder,
                    title: title
                )
                
                Spacer()
                
                editingTrailing(
                    placeholder: placeholderSecondary,
                    value: secondary
                )
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
    
    private var readonlyTrailing: some View {
        HStack(spacing: DS.Spacing.m6) {
            trailingTextContent
            
            trailingViewContent
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
        ).foregroundStyle(theme.colors.text)
        .fontWeight(.bold)
    }
    
    private func editingTrailing(
        placeholder: String,
        value: Binding<String>
    ) -> some View {
        HStack(spacing: DS.Spacing.m6) {
            TextField(
                "",
                text: value,
                prompt: Text(placeholder)
                    .font(.system(size: DSFontSize.sm.fontSize))
                    .foregroundColor(theme.colors.textSecondary)
            )
            .foregroundStyle(theme.colors.text)
            .multilineTextAlignment(.trailing)
            
            trailingViewContent
        }
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
            case .cross(let action):
                ImageIcon(name: .crossOutline, size: .sm)
                    .onTapGesture(perform: action)
            case .loading: ActivityIndicatorView(size: .sm)
            case .save(let action):
                ImageIcon(name: .saveOutline, size: .sm)
                    .onTapGesture(perform: action)
            case .delete(let action):
                ImageIcon(name: .crossOutline, size: .sm)
                    .onTapGesture(perform: action)
            case .copy(let action):
                ImageIcon(name: .copyOutline, size: .sm)
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
                .multilineTextAlignment(.trailing)
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
