import Foundation
import SwiftUI


struct BottomBar: View {
    @Environment(\.theme) var theme
    
    enum Selection {
        case home, profile, add
    }
    
    @Binding var selection: Selection
    
    var body: some View {
        HStack(spacing: DS.Spacing.m16) {
            homeIcon
            ImageIcon(name: .addOutline, size: .md)
            profileIcon
        }
        .padding(.vertical, DS.Spacing.m6)
        .padding(.horizontal, DS.Spacing.m8)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
    
    var homeIcon: ImageIcon {
        switch selection {
        case .home: ImageIcon(name: .homeFilled, size: .md)
        case .profile, .add: ImageIcon(name: .homeOutline, size: .md)
        }
    }
    
    var profileIcon: ImageIcon {
        switch selection {
        case .home, .add: ImageIcon(name: .profileOutline, size: .md)
        case .profile: ImageIcon(name: .profileFilled, size: .md)
        }
    }
}

#Preview {
    BottomBar(selection: .constant(.profile))
}
