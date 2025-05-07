import Foundation


enum DocumentIcon {
    case passport
    case driver
    case government
    case international
    case tag
}

enum DocumentColor {
    case none
    case red
    case yellow
    case green
    
    static var all: [DocumentColor] {
        [.none, .red, .green, .yellow]
    }
}
