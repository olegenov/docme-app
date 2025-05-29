import Foundation

final class AccountManager {
    static let shared = AccountManager()
    
    private init() {}
    
    var name: String = ""
    var username: String = ""
    var offlineMode: Bool = false
}
