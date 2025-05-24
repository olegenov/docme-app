import Foundation
import SwiftUI


enum DocumentListRoutes: Route, Hashable {
    case folderDetails(folder: FolderUI)
}


class DocumentListCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    private(set) var viewModel: (any DocumentListViewModel)? = nil
    
    init(container: AppDIContainer) {
        self.container = container
    }

    func start(for folder: FolderUI? = nil) -> some View {
        let provider = DocumentListProviderImpl(
            documentRepository: container.documentRepository,
            folderRepository: container.folderRepository
        )

        let vm = DocumentListViewModelImpl(
            provider: provider,
            for: folder
        )
        
        self.viewModel = vm
        
        return DocumentListView(
            viewModel: vm,
            imageService: container.imageService
        )
    }

    func addDestinations(to view: some View) -> some View {
        view.navigationDestination(for: DocumentListRoutes.self) { route in
            self.destination(for: route)
        }
    }
    
    func createNewFolder() {
        viewModel?.creatingNewFolder = true
    }
}

extension DocumentListCoordinator: BaseCoordinatorRouting {
    typealias RouteType = DocumentListRoutes

    func destination(for route: DocumentListRoutes) -> AnyView {
        switch route {
        case .folderDetails(let folder):
            return AnyView(
                DocumentListCoordinator(container: container).start(for: folder)
            )
        }
    }
}
