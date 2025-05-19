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
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Folder.self, Document.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RoutingView { documentListPath, profilePath in
                MainView(
                    documentListPath: documentListPath,
                    profileListPath: profilePath,
                    diContainer: .init(modelContext: modelContainer.mainContext)
                )
            }
        }
        .modelContainer(modelContainer)
    }
}
