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
            documentList
                .environment(\.theme, themeController.currentTheme)
        }
    }
    
    var documentList: some View {
        let provider: DocumentListProvider = DocumentListProviderImpl()
        let coordinator = DocumentListCoordinator(provider: provider)
        
        return coordinator.start()
    }
}
