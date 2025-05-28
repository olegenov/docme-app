import Foundation


struct DocumentScreenField: Identifiable, Hashable {
    let id: UUID
    var name: String
    var value: String
    
    var isEmpty: Bool {
        name.isEmpty || value.isEmpty
    }
}
