import Foundation
import SwiftUI


struct AppTabbarView: View {
    @Environment(\.theme) var theme
    
    @Binding var currentTab: Router.Tab
    
    var body: some View {
        HStack {
            homeTabbarItem
                .onTapGesture {
                    currentTab = .documents
                }
            
            Spacer()
            
            addTabbarItem
            
            Spacer()
            
            profileTabbarItem
                .onTapGesture {
                    currentTab = .profile
                }
        }
        .padding(.vertical, DS.Spacing.m6)
        .padding(.horizontal, DS.Spacing.m8)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .frame(maxWidth: 200)
        .applyShadow(theme.shadows.overlayShadow)
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
}

#Preview {
    AppTabbarView(currentTab: .constant(.documents))
}
