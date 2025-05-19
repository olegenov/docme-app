import Foundation
import SwiftUI


enum DocumentListRoutes: Route, Hashable {
    case folderDetails(folder: FolderUI)
}


@MainActor
class DocumentListCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }

    func start() -> some View {
        let provider = DocumentListProviderImpl(
            documentRepository: container.documentRepository,
            folderRepository: container.folderRepository
        )

        let viewModel = DocumentListViewModelImpl(provider: provider)

        return DocumentListView(
            viewModel: viewModel,
            imageService: container.imageService
        )
    }
    
    func destination(for route: DocumentListRoutes) -> some View {
        switch route {
        case .folderDetails(let folder):
            FolderDetailsCoordinator(container: container).start(for: folder)
        }
    }

    func addDestinations(to view: some View) -> some View {
        view.navigationDestination(for: DocumentListRoutes.self) { route in
            self.destination(for: route)
        }
    }
}
