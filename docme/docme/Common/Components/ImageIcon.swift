import Foundation
import SwiftUI


struct ImageIcon: View {
    enum Size: String {
        case sm, md
    }
    
    enum Name: String {
        case starOutline
        case starFilled
        case addOutline
        case homeOutline
        case homeFilled
        case profileOutline
        case profileFilled
        case chevronRightOutline
        case crossOutline
        case documentOutline
        case folderOutline
        case searchOutline
        case passportOutline
        case driverOutline
        case governmentOutline
        case internationalOutline
        case chevronLeftOutline
        case exitOutline
        case saveOutline
        case deleteOutline
        case tagOutline
        case editOutline
    }
    
    let name: Name
    let size: Size
    let color: Color
    
    init(name: Name, size: Size, color: Color? = nil) {
        self.name = name
        self.size = size

        if let color {
            self.color = color
        } else {
            self.color = DS.theme.colors.outline
        }
    }
    
    var body: some View {
        Image(assetName)
            .renderingMode(.template)
            .foregroundColor(color)
            .contentShape(Rectangle())
    }
    
    private var assetName: String {
        "\(name.rawValue)\(size.rawValue.firstLetterCapitalized())"
    }
}
