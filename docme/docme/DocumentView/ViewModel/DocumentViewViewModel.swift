import Foundation
import UIKit


protocol DocumentViewViewModel: ObservableObject, AnyObject {
    var document: DocumentModel? { get }
    var fields: [DocumentField] { get }
    
    var showLoading: Bool { get }
    
    func closePage()
    func editDocument()
    
    func shareDocument()
    
    func copyField(_ field: DocumentField)
    
    func loadData() async
}


@Observable
class DocumentViewViewModelImpl: DocumentViewViewModel {
    private let provider: DocumentViewProvider
    private let router = Router.shared
    
    private(set) var document: DocumentModel? = nil
    private(set) var fields: [DocumentField] = []
    private(set) var showLoading = false
    
    private let documentId: UUID
    
    init(provider: DocumentViewProvider, id: UUID) {
        self.provider = provider
        self.documentId = id
    }
    
    @MainActor
    func loadData() async {
        showLoading = true
        
        document = try? await provider.fetchDocument(
            with: documentId
        )
        
        fields = await provider.fetchFields(
            with: documentId
        )
        
        showLoading = false
    }
    
    func closePage() {
        router.popScreen(for: .documents)
    }
    
    func editDocument() {
        
    }
    
    func shareDocument() {
        
    }
    
    func copyField(_ field: DocumentField) {
        UIPasteboard.general.string = field.value
        
        ToastManager.shared.show(
            message: Captions.fieldCopied(name: field.name)
        )
    }
}
