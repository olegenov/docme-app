import Foundation
import SwiftUI


enum DS {
    static let shared = DSThemeController()
    
    static var theme: Theme {
        shared.currentTheme
    }
    
    static func setMode(_ mode: ThemeMode) {
        shared.mode = mode
    }

    static var mode: ThemeMode {
        shared.mode
    }
    
    struct Size {
        static let m = CGFloat(2)
        static let m2 = CGFloat(4)
        static let m4 = CGFloat(8)
        static let m6 = CGFloat(12)
        static let m8 = CGFloat(16)
        static let m10 = CGFloat(20)
        static let m12 = CGFloat(24)
        static let m14 = CGFloat(28)
        static let m16 = CGFloat(32)
        static let m20 = CGFloat(40)
        static let m24 = CGFloat(48)
        static let m32 = CGFloat(64)
    }

    struct Spacing {
        static let m = CGFloat(2)
        static let m2 = CGFloat(4)
        static let m4 = CGFloat(8)
        static let m6 = CGFloat(12)
        static let m8 = CGFloat(16)
        static let m10 = CGFloat(20)
        static let m12 = CGFloat(24)
        static let m14 = CGFloat(28)
        static let m16 = CGFloat(32)
        static let m20 = CGFloat(40)
        static let m24 = CGFloat(48)
        static let m32 = CGFloat(64)
    }

    struct Rounding {
        static let m = CGFloat(2)
        static let m2 = CGFloat(4)
        static let m4 = CGFloat(8)
        static let m6 = CGFloat(12)
        static let m8 = CGFloat(16)
        static let m10 = CGFloat(20)
        static let m12 = CGFloat(24)
        static let full = CGFloat.infinity
    }
}

final class DSThemeController: ObservableObject {
    @AppStorage("theme_mode") var mode: ThemeMode = .system {
        didSet { updateTheme() }
    }

    @Published private(set) var currentTheme: Theme = .light

    init() {
        updateTheme()
    }

    private func updateTheme() {
        currentTheme = Theme.resolve(using: mode)
    }
}
