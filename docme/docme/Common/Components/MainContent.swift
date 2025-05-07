import Foundation
import SwiftUI


struct MainContent<TabbarView: View, Content: View>: View {
    @Environment(\.theme) var theme
    
    @ViewBuilder let tabbar: () -> TabbarView
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            theme.gradients.background
            .ignoresSafeArea()
            
            VStack(
                alignment: .leading,
                spacing: DS.Spacing.m16
            ) {
                tabbar()
                    .padding(.horizontal, DS.Spacing.m8)
                    .zIndex(100)
                
                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: DS.Spacing.m16
                    ) {
                        content()
                        
                        Spacer()
                    }
                }.scrollClipDisabled()
            }
        }
    }
}
