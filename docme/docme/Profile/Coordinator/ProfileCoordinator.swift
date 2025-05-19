import Foundation
import SwiftUI


enum ProfileRoutes: Route, Hashable {
}


class ProfileCoordinator: ObservableObject {
    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
        self.container = container
    }

    func start() -> some View {
        let provider = ProfileProviderImpl()

        let viewModel = ProfileViewModelImpl(
            provider: provider
        )

        return ProfileView(viewModel: viewModel)
    }
}

extension ProfileCoordinator: BaseCoordinatorRouting {
    typealias RouteType = ProfileRoutes
    
    func destination(for route: ProfileRoutes) -> AnyView {
        return AnyView(EmptyView())
    }
}
