import Foundation
import SwiftUI


struct MainView: View {
    @Binding var documentListPath: NavigationPath

    @StateObject private var coordinator: DocumentListCoordinator
    
    init(
        documentListPath: Binding<NavigationPath>,
        diContainer: AppDIContainer
    ) {
        self._documentListPath = documentListPath
        self._coordinator = StateObject(
            wrappedValue: DocumentListCoordinator(container: diContainer)
        )
    }
    
    var body: some View {
        Group {
            coordinator.start()
                .addNavigationStackContainer(
                    path: $documentListPath,
                    coordinator: coordinator,
                    for: .documents
                )
        }
    }
}

private extension View {
    func addNavigationStackContainer(
        path: Binding<NavigationPath>,
        coordinator: DocumentListCoordinator,
        for tab: Router.Tab
    ) -> some View {
        NavigationStack(path: path) {
            Router.Connector.addDestinations(self, coordinator: coordinator)
        }
    }
}
