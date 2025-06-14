import Foundation
import SwiftUI
import Combine


enum DocumentListRoutes: Route, Hashable {
    case folderDetails(folder: FolderCard)
    case documentCreation(folder: FolderCard?)
    case documentView(id: UUID)
}


class DocumentListCoordinator: ObservableObject {
    var isActive = false
    private let container: AppDIContainer
    
    private(set) var viewModel: (any DocumentListViewModel)? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(container: AppDIContainer) {
        self.container = container
    }

    func start(for folder: FolderCard? = nil) -> some View {
        let provider = DocumentListProviderImpl(
            documentRepository: container.documentRepository,
            folderRepository: container.folderRepository
        )

        let vm = DocumentListViewModelImpl(
            provider: provider,
            for: folder
        )
        
        self.viewModel = vm
        
        DocumentListEventBus.shared.$event
            .sink { [weak self] event in
                guard let self,
                      self.isActive,
                      let event
                else { return }
                
                DocumentListEventBus.shared.event = nil
                
                switch event {
                case .createFolder:
                    viewModel?.creatingNewFolder = true
                case .createDocument:
                    viewModel?.createNewDocument()
                default: break
                }
            }
            .store(in: &cancellables)
        
        return DocumentListView(
            viewModel: vm,
            imageService: container.imageService
        )
        .onAppear {
            self.isActive = true
        }
        .onDisappear {
            self.isActive = false
        }
    }

    func addDestinations(to view: some View) -> some View {
        view.navigationDestination(for: DocumentListRoutes.self) { route in
            self.destination(for: route)
        }
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
        case .documentCreation(let folder):
            return AnyView(
                DocumentScreenCoordinator(container: container).start(
                    mode: .create,
                    from: folder?.id
                )
            )
        case .documentView(let documentID):
            return AnyView(
                DocumentScreenCoordinator(container: container).start(
                    mode: .view(id: documentID),
                    from: nil
                )
            )
        }
    }
}
