import Foundation
import SwiftUI


struct CloseControlView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            Color.clear
                .frame(height: DS.Size.m8)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())

            theme.colors.outline
                .frame(width: DS.Size.m12, height: DS.Size.m)
        }
    }
}
