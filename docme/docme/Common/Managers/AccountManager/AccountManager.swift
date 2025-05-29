import Foundation

final class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    private init() {}
    
    var isLoggedIn: Bool = false
    var name: String = ""
    var username: String = ""
    var offlineMode: Bool = false
    
    func logout() {
        TokenManager.shared.save(token: "")
        isLoggedIn = false
    }
}
