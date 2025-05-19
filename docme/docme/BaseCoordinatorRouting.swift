import Foundation
import SwiftUI


protocol BaseCoordinatorRouting {
    associatedtype RouteType: Route & Hashable
    
    func destination(for route: RouteType) -> AnyView
}

extension BaseCoordinatorRouting {
    func addDestinations(to view: some View) -> some View {
        view.navigationDestination(for: RouteType.self) { route in
            self.destination(for: route)
        }
    }
}
