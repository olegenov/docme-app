import Foundation


protocol AuthProvider {
    func login(data: LoginData) async -> Bool
    func signup(data: SignupData) async -> Bool
}

final class AuthProviderImpl: AuthProvider {
    let repository: AuthNetworkingRepository
    
    init(repository: AuthNetworkingRepository) {
        self.repository = repository
    }
    
    func login(data: LoginData) async -> Bool {
        await repository.login(
            username: data.username,
            password: data.password
        )
    }
    
    func signup(data: SignupData) async -> Bool {
        await repository.register(
            email: data.email,
            name: data.name,
            username: data.username,
            password: data.password
        )
    }
    
    func tryLogin() async -> Bool {
        await repository.currentUser()
    }
}
