import Foundation
import SwiftUI


extension DocumentColor {
    func toTagColor() -> TagsView.TagColor {
        switch self {
        case .none: .empty
        case .green: .green
        case .red: .red
        case .yellow: .yellow
        }
    }
    
    func toIconColor() -> Color {
        switch self {
        case .none: DS.theme.colors.outline
        case .green: DS.theme.colors.brandCyan
        case .red: DS.theme.colors.brandMagenta
        case .yellow: DS.theme.colors.brandGreen
        }
    }
}

extension DocumentIcon {
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
