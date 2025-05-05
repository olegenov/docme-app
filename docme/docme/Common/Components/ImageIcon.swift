import Foundation
import SwiftUI


struct ImageIcon: View {
    enum Size: String {
        case sm, md
    }
    
    enum Name: String {
        case starOutline
        case addOutline
        case homeOutline
        case homeFilled
        case profileOutline
        case profileFilled
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
    }
    
    private var assetName: String {
        "\(name.rawValue)\(size.rawValue.firstLetterCapitalized())"
    }
}
