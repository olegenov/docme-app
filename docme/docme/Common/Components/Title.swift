import Foundation
import SwiftUI


struct Title: View {
    @Environment(\.theme) var theme
    
    let text: String
    
    var body: some View {
        Text(text)
            .applyFont(.body(.lg, .bold))
            .foregroundStyle(theme.colors.text)
    }
}

#Preview {
    Title(text: "Hello World")
}
