import Foundation


struct DocumentField: Identifiable, Hashable {
    let id: UUID
    let name: String
    let value: String
}
