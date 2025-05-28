import Foundation
import UIKit


enum DocumentEditMode {
    case editing
    case viewing
    case creation
}

protocol DocumentScreenViewModel: ObservableObject, AnyObject {
    var editMode: DocumentEditMode { get set }
    var document: DocumentScreen { get set }
    var fields: [DocumentScreenField] { get set }
    
    var showLoading: Bool { get }
    
    func createDocument()
    
    func cancelDocumentEdit()
    func editDocument()
    
    func deleteDocument()
    
    func saveDocument()
    
    func closePage()
    
    func shareDocument()
    
    func copyField(_ field: DocumentScreenField)
    
    func loadData() async
}


@Observable
class DocumentScreenViewModelImpl: DocumentScreenViewModel {
    private let provider: DocumentScreenProvider
    private let router = Router.shared
    private let documentId: UUID
    
    var editMode: DocumentEditMode = .viewing
    var document: DocumentScreen
    var fields: [DocumentScreenField] = []
    
    private(set) var showLoading = false
    
    init(
        provider: DocumentScreenProvider,
        id: UUID = .init(),
        mode: DocumentEditMode = .viewing
    ) {
        self.provider = provider
        self.document = .init(
            title: "",
            description: "",
            image: nil,
            icon: .tag,
            color: .none
        )
        self.documentId = id
        self.editMode = mode
    }
    
    func createDocument() {
        guard document.image != nil else {
            ToastManager.shared.show(
                message: Captions.addImageFirst,
                type: .error
            )
            return
        }

        showLoading = true

        Task { [weak self] in
            guard let self else { return }

            let success = await provider.createDocument(
                documentId, document
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                showLoading = false
                
                if success {
                    ToastManager.shared.show(
                        message: Captions.successfullyCreatedDocument,
                        type: .success
                    )
                    
                    editMode = .viewing
                } else {
                    ToastManager.shared.show(
                        message: Captions.documentCreationError,
                        type: .error
                    )
                }
            }
        }
    }
    
    @MainActor
    func loadData() async {
        showLoading = true
        
        guard let loadedDocument = try? await provider.fetchDocument(
            with: documentId
        ) else {
            ToastManager.shared.show(
                message: Captions.documentGetError,
                type: .error
            )
            
            closePage()
            
            return
        }
        
        document = loadedDocument
        
        fields = await provider.fetchFields(
            with: documentId
        )
        
        showLoading = false
    }
    
    func closePage() {
        router.popScreen(for: .documents)
    }
    
    func cancelDocumentEdit() {
        editMode = .viewing
    }
    
    func editDocument() {
        editMode = .editing
    }

    func deleteDocument() {
        Task { [weak self] in
            guard let self else { return }

            let success = await provider.deleteDocument(
                with: documentId
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                showLoading = false
                
                if success {
                    closePage()
                    
                    ToastManager.shared.show(
                        message: Captions.successfullyDeletedDocument,
                        type: .success
                    )
                } else {
                    ToastManager.shared.show(
                        message: Captions.documentDeletionError,
                        type: .error
                    )
                }
            }
        }
    }
    
    func saveDocument() {
        showLoading = true

        Task { [weak self] in
            guard let self else { return }

            let success = await provider.saveDocument(with: documentId)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                showLoading = false
                
                if success {
                    editMode = .viewing
                } else {
                    ToastManager.shared.show(
                        message: Captions.documentEditError,
                        type: .error
                    )
                }
            }
        }
    }
    
    func shareDocument() {
        
    }
    
    func copyField(_ field: DocumentScreenField) {
        UIPasteboard.general.string = field.value
        
        ToastManager.shared.show(
            message: Captions.fieldCopied(name: field.name)
        )
    }
}
