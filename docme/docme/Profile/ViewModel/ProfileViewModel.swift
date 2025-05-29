import Foundation


protocol ProfileViewModel: ObservableObject, AnyObject {
    var profile: Profile { get }
    var offlineMode: Bool { get set }
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
}
