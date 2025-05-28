import Foundation
import SwiftUI
import Combine


enum DocumentCreationRoutes: Route, Hashable {
}


class DocumentCreationCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }
    
    func start() -> some View {
        let provider = DocumentCreationProviderImpl(
            documentRepository: container.documentRepository,
            imageService: container.imageService
        )
        
        let viewModel = DocumentCreationViewModelImpl(
            provider: provider
        )
        
        return DocumentCreationView(viewModel: viewModel)
    }
}
