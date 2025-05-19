import Foundation
import SwiftUI


struct ProfileView<ViewModel: ProfileViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Text("ProfileView")
    }
}
