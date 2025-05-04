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
