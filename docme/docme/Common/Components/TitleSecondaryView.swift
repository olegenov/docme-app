import Foundation
import SwiftUI


struct TitleSecondaryView: View {
    @Environment(\.theme) var theme

    let text: String
    
    var body: some View {
        Text(text)
            .applyFont(.body(.md, .bold))
            .foregroundStyle(theme.colors.text)
    }
}
