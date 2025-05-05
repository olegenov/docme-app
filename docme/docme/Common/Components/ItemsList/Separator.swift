import Foundation
import SwiftUI


struct Separator: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        theme.colors.outlineSecondary
            .frame(height: DS.Size.m05)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    Separator()
}
