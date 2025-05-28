import Foundation


final class DocumentListEventBus: ObservableObject {
    static let shared = DocumentListEventBus()
    
    @Published var event: DocumentListEvent?
    
    private init() {}
    
    func send(_ event: DocumentListEvent) {
        self.event = event
        
        DispatchQueue.main.async {
            self.event = nil
        }
    }
}

enum DocumentListEvent {
    case createFolder
    case createDocument
    case documentOpened
    case documentClosed
}
