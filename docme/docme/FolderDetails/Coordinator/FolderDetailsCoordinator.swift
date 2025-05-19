import Foundation
import SwiftUI


@MainActor
class FolderDetailsCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }

    func start(for folder: FolderUI) -> some View {
        let provider = FolderDetailsProviderImpl(
            documentRepository: container.documentRepository,
            folderRepository: container.folderRepository
        )

        let viewModel = FolderDetailsViewModelImpl(
            folder: folder,
            provider: provider
        )

        return FolderDetailsView(
            viewModel: viewModel,
            imageService: container.imageService
        )
    }
}
