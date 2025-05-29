import Foundation


protocol ProfileViewModel: ObservableObject, AnyObject {
    var profile: Profile { get }
    var offlineMode: Bool { get set }
    func logout()
}

class ProfileViewModelImpl: ProfileViewModel {
    private let provider: ProfileProvider
    private let router = Router.shared
    
    var offlineMode: Bool = false {
        didSet {
            AccountManager.shared.offlineMode = offlineMode
        }
    }
    private(set) var profile: Profile
    
    init(provider: ProfileProvider) {
        self.provider = provider
        
        self.profile = .init(
            name: AccountManager.shared.name,
            username: AccountManager.shared.username
        )
    }
    
    func logout() {
        AccountManager.shared.logout()
        
        ToastManager.shared.show(message: "Вы вышли из аккаунта", type: .error)
    }
}
