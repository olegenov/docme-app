//
//  docmeApp.swift
//  docme
//
//  Created by Никита Китаев on 04/05/2025.
//

import SwiftUI
import SwiftData

@main
struct DocmeApp: App {
    @StateObject var themeController = DS.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeController)
                .environment(\.theme, themeController.currentTheme)
        }
    }
}
