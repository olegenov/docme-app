import Foundation
import SwiftUI


enum ThemeMode: String, CaseIterable, Identifiable {
    case light, dark, system
    
    var id: String { rawValue }
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct BackgroundBlurStyle {
    let radius: CGFloat
}

struct Theme {
    let colors: Theme.Colors
    let shadows: Theme.Shadows
    let blurs: Theme.Blurs
    let gradients: Theme.Gradients

    static func resolve(using mode: ThemeMode) -> Theme {
        switch mode {
        case .light: return Theme.light
        case .dark: return Theme.dark
        case .system:
            let isDark = UITraitCollection.current.userInterfaceStyle == .dark
            return isDark ? .dark : .light
        }
    }
}

extension Theme {
    static let light = Theme(
        colors: .init(
            brandPurple: Color(hex: "#998CE2"),
            overlay: Color(hex: "#DEDAF2").opacity(0.8),
            overlaySelection: Color(hex: "#C6C3D9").opacity(0.8),
            text: Color(hex: "#2F2B45"),
            textSecondary: Color(hex: "#685F99"),
            outline: Color(hex: "#5A5285"),
            outlineSecondary: Color(hex: "#5A5285").opacity(0.2),
            brandMagenta: Color(hex: "#CC7E99"),
            brandGreen: Color(hex: "#B1BB76"),
            brandCyan: Color(hex: "#6BB29A")
        ),
        shadows: .init(
            overlayShadow: ShadowStyle(
                color: Color(hex: "#4A446E").opacity(0.1),
                radius: 8,
                x: 0,
                y: 2
            )
        ),
        blurs: .init(overlayBackgroundBlur: .init(radius: 8)),
        gradients: .init(
            background: RadialGradient(
                gradient: Gradient(
                    colors: [Color(hex: "#E28CA9"), Color(hex: "#998CE2")]
                ),
                center: UnitPoint(x: 0.14, y: 0.14),
                startRadius: 0,
                endRadius: 800
            )
        )
    )

    static let dark = Theme(
        colors: .init(
            brandPurple: Color(hex: "#998CE2"),
            overlay: Color(hex: "#333238").opacity(0.8),
            overlaySelection: Color(hex: "#2F2E33").opacity(0.8),
            text: Color(hex: "#EAE9F2"),
            textSecondary: Color(hex: "#ADA3E5"),
            outline: Color(hex: "#8A7ECC"),
            outlineSecondary: Color(hex: "#8A7ECC").opacity(0.2),
            brandMagenta: Color(hex: "#D986A3"),
            brandGreen: Color(hex: "#BCC77E"),
            brandCyan: Color(hex: "#72BFA5")
        ),
        shadows: .init(
            overlayShadow: ShadowStyle(
                color: Color(hex: "#4A446E").opacity(0.1),
                radius: 8,
                x: 0,
                y: 2
            )
        ),
        blurs: .init(overlayBackgroundBlur: .init(radius: 8)),
        gradients: .init(
            background: RadialGradient(
                gradient: Gradient(colors: [Color(hex: "#2C181E"), Color(hex: "#161422")]),
                center: UnitPoint(x: 0.14, y: 0.14),
                startRadius: 0,
                endRadius: 800
            )
        )
    )
}

extension Theme {
    struct Shadows {
        let overlayShadow: ShadowStyle
    }

    struct Blurs {
        let overlayBackgroundBlur: BackgroundBlurStyle
    }

    struct Gradients {
        let background: RadialGradient
    }

    struct Colors {
        let brandPurple: Color
        let overlay: Color
        let overlaySelection: Color
        let text: Color
        let textSecondary: Color
        let outline: Color
        let outlineSecondary: Color
        let brandMagenta: Color
        let brandGreen: Color
        let brandCyan: Color
    }
}

private struct ThemeKey: EnvironmentKey {
    static var defaultValue: Theme {
        DS.theme
    }
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
