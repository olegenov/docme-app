import Foundation
import SwiftUI


struct AppTabbarView: View {
    @Environment(\.theme) var theme
    
    @Binding var currentTab: Router.Tab
    
    let onFolderCreation: () -> Void
    
    @State private var isExtended: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        Group {
            if isExtended {
                isExtendedView
            } else {
                defaultView
            }
        }
        .padding(.top, isExtended ? 0: DS.Spacing.m6)
        .padding(.bottom, DS.Spacing.m6)
        .padding(.horizontal, DS.Spacing.m8)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
    
    private var defaultView: some View {
        HStack {
            homeTabbarItem
                .onTapGesture {
                    currentTab = .documents
                }
            
            Spacer()
            
            addTabbarItem
                .onTapGesture {
                    currentTab = .documents
                    
                    withAnimation {
                        isExtended = true
                    }
                }
            
            Spacer()
            
            profileTabbarItem
                .onTapGesture {
                    currentTab = .profile
                }
        }.frame(maxWidth: 170)
    }
    
    private var isExtendedView: some View {
        VStack {
            closeExtendedActionBar
            
            VStack(spacing: DS.Spacing.m4) {
                ListItemView(
                    configuration: .defaultStyle(
                        title: Captions.addFolder,
                        leadingView: .icon(
                            .init(name: .folderOutline, size: .md)
                        )
                    ),
                    trailingView: .chevron,
                    onTapAction:  {
                        onFolderCreation()
                        currentTab = .documents
                        
                        withAnimation {
                            isExtended = false
                        }
                    }
                )
                
                SeparatorView()
                
                ListItemView(
                    configuration: .defaultStyle(
                        title: Captions.addDocument,
                        leadingView: .icon(
                            .init(name: .documentOutline, size: .md)
                        )
                    ),
                    trailingView: .chevron,
                    onTapAction:  {
                        
                    }
                )
            }
        }
        .frame(maxWidth: 270)
    }
    
    private var homeTabbarItem: some View {
        ImageIcon(
            name: currentTab == .documents ? .homeFilled : .homeOutline,
            size: .md
        )
    }
    
    private var addTabbarItem: some View {
        ImageIcon(
            name: .addOutline,
            size: .md
        )
    }
    
    private var profileTabbarItem: some View {
        ImageIcon(
            name: currentTab == .profile ? .profileFilled : .profileOutline,
            size: .md
        )
    }
    
    private var closeExtendedActionBar: some View {
        CloseControlView()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 50 {
                            withAnimation {
                                isExtended = false
                            }
                        }
                    }
            )
    }
}
