import Foundation
import SwiftUI
import Combine


class AuthCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }
    
    func start(onSuccess: @escaping () -> Void) -> some View {
        let provider = AuthProviderImpl(
            repository: container.authNetworking
        )
        
        let viewModel = AuthViewModelImpl(
            provider: provider,
            onSuccess: onSuccess
        )
        
        return AuthView(viewModel: viewModel)
    }
}
