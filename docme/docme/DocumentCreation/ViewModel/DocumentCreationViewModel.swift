import Foundation
import UIKit


protocol DocumentCreationViewModel: ObservableObject, AnyObject {
    var documentTitle: String { get set }
    var documentDescription: String { get set }
    var documentIcon: DocumentCardUI.Icon { get set }
    var documentColor: DocumentCardUI.Color { get set }
    var documentImage: UIImage? { get set }
    
    var showLoading: Bool { get }
    
    func cancelDocumentCreation()
    func createDocument()
}


@Observable
class DocumentCreationViewModelImpl: DocumentCreationViewModel {
    private let provider: DocumentCreationProvider
    private let router = Router.shared
    
    var documentTitle: String = ""
    var documentDescription: String = ""
    var documentIcon: DocumentCardUI.Icon = .tag
    var documentColor: DocumentCardUI.Color = .none
    var documentImage: UIImage? = nil
    
    private(set) var showLoading = false
    
    init(provider: DocumentCreationProvider) {
        self.provider = provider
    }
    
    func cancelDocumentCreation() {
        router.popScreen(for: .documents)
    }
    
    func createDocument() {
        guard let documentImage else {
            ToastManager.shared.show(
                message: Captions.addImageFirst,
                type: .error
            )
            return
        }

        showLoading = true

        Task { [weak self] in
            guard let self else { return }

            let documentID = await provider.saveDocument(
                .init(
                    title: documentTitle,
                    description: documentDescription,
                    image: documentImage,
                    type: documentIcon.toDomain(),
                    color: documentColor.toDomain()
                )
            )

            DispatchQueue.main.async {
                self.showLoading = false

                if let documentID {
                    Router.shared.popScreen(
                        for: .documents,
                        withAnimation: false
                    )
                    Router.shared.pushScreen(
                        DocumentListRoutes.documentView(id: documentID),
                        for: .documents
                    )
                    ToastManager.shared.show(
                        message: Captions.successfullyCreatedDocument,
                        type: .success
                    )
                } else {
                    ToastManager.shared.show(
                        message: Captions.documentCreationError,
                        type: .error
                    )
                }
            }
        }
    }
}

private extension DocumentCardUI.Color {
    func toDomain() -> Document.Color {
        switch self {
        case .green: .green
        case .none: .none
        case .red: .red
        case .yellow: .yellow
        }
    }
}

private extension DocumentCardUI.Icon {
    func toDomain() -> Document.Icon {
        switch self {
        case .driver: .driver
        case .government: .government
        case .international: .international
        case .passport: .passport
        case .tag: .tag
        }
    }
}
