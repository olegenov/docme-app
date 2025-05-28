import Foundation
import SwiftUI
import Combine


enum DocumentViewRoutes: Route, Hashable {
}


class DocumentViewCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }
    
    func start(for id: UUID) -> some View {
        let provider = DocumentViewProviderImpl(
            documentRepository: container.documentRepository,
            imageService: container.imageService
        )
        
        let viewModel = DocumentViewViewModelImpl(
            provider: provider,
            id: id
        )
        
        return DocumentViewView(viewModel: viewModel)
    }
}
