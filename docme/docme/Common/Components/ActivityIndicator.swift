import Foundation
import SwiftUI


struct ActivityIndicator: View {
    @Environment(\.theme) var theme
    
    enum Size {
        case md, sm
    }
    
    let size: Size
    
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat = 0.5
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: trimStart, to: trimEnd)
                .stroke(theme.colors.outline, lineWidth: 2)
                .frame(width: iconSize, height: iconSize)
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
    
    private var iconSize: CGFloat {
        switch size {
        case .md:
            return DS.Size.m12
        case .sm:
            return DS.Size.m6
        }
    }
}

#Preview {
    VStack {
        ActivityIndicator(size: .md)
        ActivityIndicator(size: .sm)
    }
}
