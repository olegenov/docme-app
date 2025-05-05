import Foundation
import SwiftUI


struct ItemsList<Content: View>: View {
    @Environment(\.theme) var theme
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .padding(.vertical, DS.Spacing.m4)
            .padding(.horizontal, DS.Spacing.m8)
            .background(theme.colors.overlay)
            .cornerRadius(DS.Spacing.m8)
            .applyShadow(theme.shadows.overlayShadow)
    }
}
