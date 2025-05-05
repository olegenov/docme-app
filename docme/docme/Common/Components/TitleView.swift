import Foundation
import SwiftUI


struct TitleView: View {
    @Environment(\.theme) var theme
    
    let text: String
    
    var body: some View {
        Text(text)
            .applyFont(.body(.lg, .bold))
            .foregroundStyle(theme.colors.text)
    }
}

#Preview {
    TitleView(text: "Hello World")
}
