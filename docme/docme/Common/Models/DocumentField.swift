import Foundation
import SwiftData


@Model
final class DocumentField: UUIDModel {
    var uuid: UUID
    var name: String
    var value: String
    
    @Relationship(deleteRule: .nullify) var document: Document
    
    init(
        id: UUID = UUID(),
        name: String,
        value: String,
        document: Document
    ) {
        self.uuid = id
        self.name = name
        self.value = value
        self.document = document
    }
}
