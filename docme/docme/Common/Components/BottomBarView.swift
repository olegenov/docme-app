import Foundation
import SwiftUI


struct BottomBarView: View {
    @Environment(\.theme) var theme
    
    enum Selection {
        case home, profile, add, addDocument
    }
    
    @Binding var selection: Selection
    
    let homeTapAction: () -> Void
    let profileTapAction: () -> Void
    let addTapAction: () -> Void
    let onCloseAction: () -> Void
    let onAddDocumentTapAction: () -> Void
    
    var body: some View {
        HStack {
            switch selection {
            case .home, .profile: defaultView
            case .add: extendedView
            case .addDocument: addDocumentView
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, DS.Spacing.m6)
        .padding(.horizontal, DS.Spacing.m8)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
        .animation(.easeInOut, value: selection)
        .frame(maxWidth: 250)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if selection == .home || selection == .profile { return }
                    if gesture.translation.height > 0 {
                        onCloseAction()
                    }
                }
        )
    }
    
    private var homeIcon: ImageIcon {
        switch selection {
        case .home: ImageIcon(name: .homeFilled, size: .md)
        case .profile, .add, .addDocument: ImageIcon(name: .homeOutline, size: .md)
        }
    }
    
    private var profileIcon: ImageIcon {
        switch selection {
        case .home, .add, .addDocument: ImageIcon(name: .profileOutline, size: .md)
        case .profile: ImageIcon(name: .profileFilled, size: .md)
        }
    }
    
    private var defaultView: some View {
        HStack(spacing: DS.Spacing.m16) {
            homeIcon
                .onTapGesture(perform: homeTapAction)
            
            ImageIcon(name: .addOutline, size: .md)
                .onTapGesture(perform: addTapAction)
            
            profileIcon
                .onTapGesture(perform: profileTapAction)
        }
    }
    
    private var extendedView: some View {
        VStack(spacing: DS.Spacing.m4) {
            closeBar
            
            ListItemView(
                title: Captions.addFolder,
                leadingView: .icon(
                    .init(name: .folderOutline, size: .md)
                ),
                trailingView: .chevron,
                onTapAction: { }
            )
            
            SeparatorView()
            
            ListItemView(
                title: Captions.addDocument,
                leadingView: .icon(
                    .init(name: .documentOutline, size: .md)
                ),
                trailingView: .chevron,
                onTapAction: onAddDocumentTapAction
            )
        }
    }
    
    private var addDocumentView: some View {
        VStack(spacing: DS.Spacing.m4) {
            closeBar
            
            ListItemView(
                title: Captions.camera,
                trailingView: .chevron,
                onTapAction: { }
            )
            
            SeparatorView()
            
            ListItemView(
                title: Captions.gallery,
                trailingView: .chevron,
                onTapAction: { }
            )
            
            SeparatorView()
            
            ListItemView(
                title: Captions.files,
                trailingView: .chevron,
                onTapAction: { }
            )
        }
    }
    
    private var closeBar: some View {
        Capsule()
            .fill(theme.colors.outline)
            .frame(width: DS.Size.m12, height: DS.Size.m)
    }
    
    private var topPadding: CGFloat {
        switch selection {
        case .add, .addDocument:
            return DS.Spacing.m4
        case .home, .profile:
            return DS.Spacing.m6
        }
    }
}

#Preview {
    @Previewable @State var selected: BottomBarView.Selection = .home
    
    BottomBarView(
        selection: $selected,
        homeTapAction: {
            selected = .home
        },
        profileTapAction: {
            selected = .profile
        },
        addTapAction: {
            selected = .add
        },
        onCloseAction: {
            selected = .home
        },
        onAddDocumentTapAction: {
            selected = .addDocument
        }
    )
}
