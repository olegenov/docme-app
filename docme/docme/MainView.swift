import Foundation
import SwiftUI


struct MainView: View {
    @Binding var documentListPath: NavigationPath
    @Binding var profileListPath: NavigationPath
    
    @StateObject private var documentListCoordinator: DocumentListCoordinator
    @StateObject private var profileCoordinator: ProfileCoordinator
    
    @ObservedObject private var themeController = DS.shared
    
    @State private var currentTab: Router.Tab = .documents
    
    init(
        documentListPath: Binding<NavigationPath>,
        profileListPath: Binding<NavigationPath>,
        diContainer: AppDIContainer
    ) {
        self._documentListPath = documentListPath
        self._profileListPath = profileListPath
        
        self._documentListCoordinator = StateObject(
            wrappedValue: DocumentListCoordinator(container: diContainer)
        )
        self._profileCoordinator = StateObject(
            wrappedValue: ProfileCoordinator(container: diContainer)
        )
    }
    
    var body: some View {
        tabView
            .environment(
                \.theme,
                 themeController.currentTheme
            )
    }
    
    private var tabView: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Group {
                    switch currentTab {
                    case .documents:
                        documentListCoordinator.start()
                            .addNavigationStackContainer(
                                path: $documentListPath,
                                coordinator: documentListCoordinator,
                                for: .documents
                            )
                    case .profile:
                        profileCoordinator.start()
                            .addNavigationStackContainer(
                                path: $profileListPath,
                                coordinator: profileCoordinator,
                                for: .profile
                            )
                    }
                }
                Spacer(minLength: 0)
            }

            AppTabbarView(currentTab: $currentTab)
                .padding(.bottom, DS.Spacing.m20)
                .padding(.horizontal)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private extension View {
    func addNavigationStackContainer<Coordinator: BaseCoordinatorRouting>(
        path: Binding<NavigationPath>,
        coordinator: Coordinator,
        for tab: Router.Tab
    ) -> some View {
        NavigationStack(path: path) {
            coordinator.addDestinations(to: self)
        }
    }
}
