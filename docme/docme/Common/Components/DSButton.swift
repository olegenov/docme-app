import Foundation
import SwiftUI


struct DSButton: View {
    @Environment(\.theme) var theme
    
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Text(text)
            .applyFont(.body(.sm, .bold))
            .padding(DS.Spacing.m8)
            .background(theme.colors.brandCyan)
            .cornerRadius(DS.Spacing.m8)
            .onTapGesture(perform: onTap)
    }
}
