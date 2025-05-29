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
    
    var isSharing: Bool { get set }
    var textFileURL: URL? { get }
    
    var showLoading: Bool { get }
    
    func createDocument()
    
    func cancelDocumentEdit()
    func editDocument()
    
    func deleteDocument()
    
    func saveDocument()
    
    func closePage()
    
    func shareDocument()
    
    func copyField(_ field: DocumentScreenField)
    func deleteField(_ field: DocumentScreenField)
    
    func loadData() async
}


@Observable
class DocumentScreenViewModelImpl: DocumentScreenViewModel {
    private let provider: DocumentScreenProvider
    private let router = Router.shared
    private let documentId: UUID
    private let folderId: UUID?
    
    var textFileURL: URL? = nil
    
    var isSharing: Bool = false
    var editMode: DocumentEditMode = .viewing
    var document: DocumentScreen
    var fields: [DocumentScreenField] = [] {
        didSet {
            if editMode != .editing { return }
            ensureEmptyFieldExists()
        }
    }
    
    private(set) var showLoading = false
    
    init(
        provider: DocumentScreenProvider,
        id: UUID = .init(),
        folderId: UUID? = nil,
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
        self.folderId = folderId
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
                documentId, document, in: folderId
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                showLoading = false
                
                if success {
                    ToastManager.shared.show(
                        message: Captions.successfullyCreatedDocument,
                        type: .success
                    )
                    
                    if document.title.isEmpty {
                        document.title = Captions.newDocument
                    }
                    
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
        
        let loadedFields = try? await provider.fetchFields(
            with: documentId
        )
        
        if loadedFields == nil {
            ToastManager.shared.show(
                message: Captions.fieldsGetError,
                type: .error
            )
        }
        
        fields = loadedFields ?? []
        
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
        ensureEmptyFieldExists()
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

            let success = await provider.saveDocument(
                with: documentId,
                fields: fields
            )

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                showLoading = false
                
                if success {
                    if document.title.isEmpty {
                        document.title = Captions.newDocument
                    }
                    cancelDocumentEdit()
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
        let textContent = composeTextFileContent()

        do {
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("export.txt")

            try textContent.write(to: fileURL, atomically: true, encoding: .utf8)

            textFileURL = fileURL
            isSharing = true
        } catch {
            AppLogger.shared.error("Ошибка при записи файла: \(error)")
            
            ToastManager.shared.show(
                message: "Ошибка при экспорте",
                type: .error
            )
        }
    }
    
    func deleteField(_ field: DocumentScreenField) {
        fields.removeAll { $0.id == field.id }
    }
    
    func copyField(_ field: DocumentScreenField) {
        UIPasteboard.general.string = field.value
        
        ToastManager.shared.show(
            message: Captions.fieldCopied(name: field.name)
        )
    }
    
    func composeTextFileContent() -> String {
        var result = ""
        
        for field in fields {
            result += "\(field.name): \(field.value)\n"
        }
        
        return result
    }
}

private extension DocumentScreenViewModel {
    func ensureEmptyFieldExists() {
        guard let last = fields.last else {
            fields.append(DocumentScreenField(id: .init(), name: "", value: ""))
            return
        }

        if !last.name.isEmpty || !last.value.isEmpty {
            fields.append(DocumentScreenField(id: .init(), name: "", value: ""))
        }
    }
}
