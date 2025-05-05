import Foundation
import SwiftUI


struct TopBarView: View {
    enum State {
        case main(selectedColors: [TagView.TagColor])
        case search
        case navigation(previuousPage: String)
        case navigationHome(previuousPage: String)
        case tagFilter
        case documentCreation
        case documentView
        case documentEdit
        case login
        case signup
    }
    
    var body: some View {
        EmptyView()
    }
}
