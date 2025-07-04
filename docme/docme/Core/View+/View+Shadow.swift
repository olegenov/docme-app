import Foundation
import SwiftUI


extension View {
    func applyShadow(_ shadow: ShadowStyle) -> some View {
        self
            .modifier(
                DSShadowModifier(
                    shadow: shadow
                )
            )
    }
}

struct DSShadowModifier: ViewModifier {
    let shadow: ShadowStyle

    func body(content: Content) -> some View {
        content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}


extension UIImageView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
