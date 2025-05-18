import Foundation

struct DocumentCardUI: Identifiable, Hashable {
    let id: UUID
    let title: String
    let imageUrl: String
    let icon: Icon
    let color: Color
    let description: String?
    let isFavorite: Bool
    let createdAt: Date
    let folderId: UUID?
    
    enum Icon: String, Hashable {
        case passport
        case driver
        case government
        case international
        case tag
    }
    
    enum Color: String, Hashable {
        case none
        case red
        case green
        case yellow
        
        static var all: [Color] {
            [.none, .red, .green, .yellow]
        }
    }
    
    init(
        id: UUID,
        title: String,
        imageUrl: String,
        icon: Icon,
        color: Color,
        description: String?,
        isFavorite: Bool,
        createdAt: Date,
        folderId: UUID?
    ) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.icon = icon
        self.color = color
        self.description = description
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.folderId = folderId
    }
}

extension Document.Icon {
    func toModelIcon() -> DocumentCardUI.Icon {
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
    func toModelColor() -> DocumentCardUI.Color {
        switch self {
        case .none: .none
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
}

extension DocumentCardUI.Color {
    func toTagColor() -> TagsView.TagColor {
        switch self {
        case .none: .empty
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
}

extension DocumentCardUI.Icon {
    func toTagIconName() -> ImageIcon.Name? {
        switch self {
        case .driver: .driverOutline
        case .government: .governmentOutline
        case .passport: .passportOutline
        case .international: .internationalOutline
        case .tag: nil
        }
    }
}

extension Document {
    func toCardUI() -> DocumentCardUI {
        .init(
            id: uuid,
            title: title,
            imageUrl: "", // TODO: Implement images
            icon: icon.toModelIcon(),
            color: color.toModelColor(),
            description: documentDescription,
            isFavorite: isFavorite,
            createdAt: createdAt,
            folderId: folder?.uuid
        )
    }
}
