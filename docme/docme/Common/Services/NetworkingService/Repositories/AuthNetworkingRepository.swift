import Foundation


struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct RegisterRequest: Codable {
    let email: String
    let name: String
    let username: String
    let password: String
}

struct UserResponse: Codable {
    struct User: Codable {
        var username: String
        var name: String
    }
    
    let data: User
}

struct RegisterResponse: Decodable {
    let messsgae: String
}

final class AuthNetworkingRepository {
    private let networkingService: NetworkingService
    
    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }
    
    func login(username: String, password: String) async -> Bool {
        let request = LoginRequest(username: username, password: password)
        
        var result: Result<LoginResponse, Error>? = nil
        
        await networkingService.postIgnoringToken(path: "/auth/login", requestObject: request) { response in
            result = response
        }
        
        switch result {
        case .success(let loginResponse):
            let success = TokenManager.shared.save(token: loginResponse.token)
            return success
        case .failure(let error):
            return false
        case .none:
            return false
        }
    }
    
    func register(email: String, name: String, username: String, password: String) async -> Bool {
        let request = RegisterRequest(
            email: email,
            name: name,
            username: username,
            password: password
        )
        
        var result: Result<RegisterResponse, Error>? = nil
        
        await networkingService.postIgnoringToken(path: "/auth/register", requestObject: request) { response in
            result = response
        }
        
        switch result {
        case .success(let registerResponse):
            return true
        case .failure(let error):
            return false
        case .none:
            return false
        }
    }
    
    func currentUser() async -> Bool {
        guard let token = TokenManager.shared.retrieve() else {
            return false
        }
        
        var result: Result<UserResponse, Error>? = nil
        
        await networkingService.get(path: "/users/me") { response in
            result = response
        }
        
        switch result {
        case .success(let result):
            AccountManager.shared.name = result.data.name
            AccountManager.shared.username = result.data.username
            
            return true
        case .failure(let error):
            return false
        case .none:
            return false
        }
    }
}

