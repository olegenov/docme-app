import Foundation


enum DSFontSize {
    case sm, md, lg
    
    var lineHeight: CGFloat {
        switch self {
        case .sm: return 16
        case .md: return 24
        case .lg: return 42
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return 14
        case .md: return 20
        case .lg: return 36
        }
    }
}

enum DSFontWeight {
    case regular, bold
}

enum DSTextStyle {
    case body(DSFontSize, DSFontWeight)
}
