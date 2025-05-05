import Foundation
import SwiftUI


struct ActivityIndicator: View {
    @Environment(\.theme) var theme
    
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat = 0.5
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: trimStart, to: trimEnd)
                .stroke(theme.colors.outline, lineWidth: 2)
                .frame(width: DS.Size.m12, height: DS.Size.m12)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotation = 360
                    }

                    withAnimation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                    ) {
                        trimEnd = 0.9
                    }
                }
        }
    }
}

#Preview {
    ActivityIndicator()
}
