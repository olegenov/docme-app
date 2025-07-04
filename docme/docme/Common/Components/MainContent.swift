import Foundation
import SwiftUI


struct MainContent<Content: View>: View {
    @Environment(\.theme) var theme
    
    var alignment: HorizontalAlignment = .leading
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            theme.gradients.background
                .ignoresSafeArea()
            
            VStack(
                alignment: alignment,
                spacing: DS.Spacing.m16
            ) {
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MainScrollView<Content: View>: View {
    @Environment(\.theme) var theme
    
    var scrollClipDisabled = true
    
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DS.Spacing.m16) {
                content()
            }
            .frame(maxWidth: .infinity)
            .scrollClipDisabled(scrollClipDisabled)
        }
    }
}
