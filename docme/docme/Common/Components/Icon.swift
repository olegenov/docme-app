import Foundation
import SwiftUI


struct ImageIcon: View {
    enum Size: String {
        case sm, md
    }
    
    enum Name: String {
        case starOutline
    }
    
    let name: Name
    let size: Size
    let color: Color
    
    var body: some View {
        Image(assetName)
            .renderingMode(.template)
            .foregroundColor(color)
    }
    
    private var assetName: String {
        "\(name.rawValue)\(size.rawValue.firstLetterCapitalized())"
    }
}
