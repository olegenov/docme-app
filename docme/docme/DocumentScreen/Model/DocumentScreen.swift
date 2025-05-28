import Foundation
import UIKit


struct DocumentScreen {
    var title: String
    var description: String
    var image: UIImage?
    var icon: Icon
    var color: Color
    
    enum Icon: String, Hashable {
        case passport
        case driver
        case government
        case international
        case tag
    }
    
    enum Color: String, Hashable, Codable {
        case none
        case red
        case green
        case yellow
        
        static var all: [Color] {
            [.none, .red, .green, .yellow]
        }
    }
}

extension Document.Icon {
    func toModelIcon() -> DocumentScreen.Icon {
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
    func toModelColor() -> DocumentScreen.Color {
        switch self {
        case .none: .none
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
}

extension DocumentScreen.Color {
    func toTagColor() -> TagsView.TagColor {
        switch self {
        case .none: .empty
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
    
    func toDomain() -> Document.Color {
        switch self {
        case .green: .green
        case .none: .none
        case .red: .red
        case .yellow: .yellow
        }
    }
}

extension DocumentScreen.Icon {
    func toTagIconName() -> ImageIcon.Name {
        switch self {
        case .driver: .driverOutline
        case .government: .governmentOutline
        case .passport: .passportOutline
        case .international: .internationalOutline
        case .tag: .tagOutline
        }
    }
    
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
