import Foundation
import SwiftUI


class DocumentListCoordinator {
    private let provider: DocumentListProvider

    init(provider: DocumentListProvider) {
        self.provider = provider
    }

    func start() -> some View {
        let viewModel = DocumentListViewModelImpl(provider: provider)
        return DocumentListView(viewModel: viewModel, imageManager: DefaultImageManager.shared)
    }
}
