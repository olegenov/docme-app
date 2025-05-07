import Foundation
import SwiftUI


struct TitledContent<Content: View>: View {
    @Environment(\.theme) var theme
    
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m4) {
            TitleView(text: title)
            
            content()
        }.padding(.horizontal, DS.Spacing.m8)
    }
}

#Preview {
    TitledContent(title: "123") {
        Text("1123")
    }
}
