import Foundation


final class DocumentListEventBus: ObservableObject {
    static let shared = DocumentListEventBus()
    
    @Published var event: DocumentListEvent?
    
    private init() {}
    
    func send(_ event: DocumentListEvent) {
        self.event = event
    }
}

enum DocumentListEvent {
    case createFolder
    case createDocument
    case documentCreationClosed
}
