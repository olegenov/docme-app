import Foundation
import SwiftUI
import Combine


class DocumentScreenCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    enum Mode {
        case create
        case view(id: UUID)
    }
    
    init(container: AppDIContainer) {
        self.container = container
    }
    
    func start(mode: Mode) -> some View {
        let provider = DocumentScreenProviderImpl(
            documentRepository: container.documentRepository,
            fieldRepository: container.fieldRepository,
            imageService: container.imageService
        )
        
        let viewModel = switch mode {
        case .create:
            DocumentScreenViewModelImpl(
                provider: provider,
                mode: .creation
            )
        case .view(let id):
            DocumentScreenViewModelImpl(
                provider: provider,
                id: id,
                mode: .viewing
            )
        }

        return DocumentScreenView(viewModel: viewModel)
    }
}
