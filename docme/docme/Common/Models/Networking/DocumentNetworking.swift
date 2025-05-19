import Foundation


struct DocumentNetworking {
    let uuid: UUID
    let title: String
    let imageUrl: String?
    let icon: Icon
    let color: Color
    let description: String?
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date
    let folderId: UUID?
    
    enum Icon: String, Codable {
        case passport
        case driver
        case government
        case international
        case tag
    }
    
    enum Color: String, Codable {
        case none
        case red
        case green
        case yellow
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        imageUrl: String?,
        icon: Icon,
        color: Color,
        description: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        folderId: UUID? = nil
    ) {
        self.uuid = id
        self.title = title
        self.imageUrl = imageUrl
        self.icon = icon
        self.color = color
        self.description = description
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.folderId = folderId
    }
}

extension Document.Icon {
    func toNetworkingIcon() -> DocumentNetworking.Icon {
        switch self {
        case .driver: .driver
        case .government: .government
        case .passport: .passport
        case .international: .international
        case .tag: .tag
        }
    }
}

extension Document.Color {
    func toNetworkingColor() -> DocumentNetworking.Color {
        switch self {
        case .none: .none
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
}

extension DocumentNetworking.Icon {
    func toDomain() -> Document.Icon {
        switch self {
        case .passport: .passport
        case .driver: .driver
        case .government: .government
        case .international: .international
        case .tag: .tag
        }
    }
}

extension DocumentNetworking.Color {
    func toDomain() -> Document.Color {
        switch self {
        case .none: .none
        case .red: .red
        case .green: .green
        case .yellow: .yellow
        }
    }
}
