import Foundation
import SwiftUI


extension Router {
    enum Tab: Hashable, CaseIterable {
        case documents
        case profile
    }
}

protocol Route: Hashable { }

@MainActor
struct RoutingView<Root: View>: View {
    @State private var documentsPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    @State private var didSetHandlers = false
    
    let rootView: (
        _ documentListPath: Binding<NavigationPath>,
        _ profilePath: Binding<NavigationPath>
    ) -> Root
    
    init(
        @ViewBuilder rootView: @escaping (
            _ documentListPath: Binding<NavigationPath>,
            _ profilePath: Binding<NavigationPath>
        ) -> Root
    ) {
        self.rootView = rootView
    }
    
    var body: some View {
        rootView($documentsPath, $profilePath)
            .onAppear {
                Router.shared.setHandlers(
                    push: { route, tab, animated in
                        pushScreen(route, for: tab, withAnimation: animated)
                    },
                    pop: { count, tab, animated in
                        popScreen(count: count, for: tab, withAnimation: animated)
                    }
                )
            }
    }
    
    func pushScreen(
        _ screen: any Route,
        for tab: Router.Tab,
        withAnimation: Bool = true
    ) {
        var transaction = Transaction()
        transaction.disablesAnimations = !withAnimation
        
        withTransaction(transaction) {
            documentsPath.append(screen)
        }
    }
    
    func popScreen(
        count: Int = 1,
        for tab: Router.Tab,
        withAnimation: Bool = true
    ) {
        var transaction = Transaction()
        transaction.disablesAnimations = !withAnimation
        withTransaction(transaction) {
            documentsPath.safeRemoveLast(count)
        }
    }
}


final class Router {
    static let shared = Router()
    
    private init() {}

    fileprivate typealias PushScreenHandler = (
        _ screen: any Route,
        _ tab: Router.Tab,
        _ withAnimation: Bool
    ) -> Void
    
    fileprivate typealias ResetScreenHandler = (
        _ count: Int,
        _ tab: Router.Tab,
        _ withAnimation: Bool
    ) -> Void
    
    fileprivate var pushScreenHandler: PushScreenHandler?
    fileprivate var popScreenHandler: ResetScreenHandler?
    
    fileprivate func setHandlers(
        push: @escaping PushScreenHandler,
        pop: @escaping ResetScreenHandler
    ) {
        self.pushScreenHandler = push
        self.popScreenHandler = pop
    }
    
    func pushScreen(
        _ screen: any Route,
        for tab: Router.Tab,
        withAnimation: Bool = true
    ) {
        self.pushScreenHandler?(screen, tab, withAnimation)
    }
    
    func popScreen(
        count: Int = 1,
        for tab: Router.Tab,
        withAnimation: Bool = true
    ) {
        self.popScreenHandler?(count, tab, withAnimation)
    }
    
    func resetToRoot(
        for tab: Router.Tab,
        withAnimation: Bool = true
    ) {
        popScreen(
            count: Int.max,
            for: tab,
            withAnimation: withAnimation
        )
    }
}

extension NavigationPath {
    fileprivate mutating func safeRemoveLast(_ count: Int) {
        let count = max(0, min(count, self.count))
        removeLast(count)
    }
}
