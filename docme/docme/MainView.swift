import Foundation
import SwiftUI


struct MainView: View {
    @Environment(\.theme) var theme
    
    @Binding var documentListPath: NavigationPath
    @Binding var profilePath: NavigationPath
    
    @StateObject private var documentListCoordinator: DocumentListCoordinator
    @StateObject private var profileCoordinator: ProfileCoordinator
    @StateObject private var toastManager = ToastManager.shared
    
    @ObservedObject private var themeController = DS.shared
    
    @State private var currentTab: Router.Tab = .documents
    @State private var isTabbarVisible: Bool = true
    
    init(
        documentListPath: Binding<NavigationPath>,
        profilePath: Binding<NavigationPath>,
        diContainer: AppDIContainer
    ) {
        self._documentListPath = documentListPath
        self._profilePath = profilePath
        
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
            .animation(.easeInOut, value: isTabbarVisible)
            .background(theme.gradients.background)
            .onReceive(DocumentListEventBus.shared.$event.compactMap { $0 }) { event in
                switch event {
                case .documentCreationClosed:
                    isTabbarVisible = true
                default:
                    break
                }
            }
            .overlay(alignment: .top) {
                toastView
            }
    }
    
    private var toastView: some View {
        Group {
            if let toast = toastManager.toast {
                ToastView(toast: toast)
            }
        }
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
                                path: $profilePath,
                                coordinator: profileCoordinator,
                                for: .profile
                            )
                    }
                }
                Spacer(minLength: 0)
            }

            AppTabbarView(
                currentTab: $currentTab,
                onFolderCreation: {
                    DocumentListEventBus.shared.send(.createFolder)
                },
                onDocumentCreation: {
                    isTabbarVisible = false
                    
                    DocumentListEventBus.shared.send(.createDocument)
                },
                isTabbarVisible: $isTabbarVisible
            )
                .padding(.bottom, DS.Spacing.m20)
                .padding(.horizontal)
                .opacity(isTabbarVisible ? 1 : 0)
                .offset(y: isTabbarVisible ? 0 : 20)
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
