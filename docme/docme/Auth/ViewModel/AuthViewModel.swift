import Foundation


protocol AuthViewModel: ObservableObject, AnyObject {
    var loginData: LoginData { get set }
    var signupData: SignupData { get set }
    var state: AuthState { get set }
    
    func login()
    func register()
    func validatePassword() -> String?
    func validateEmail() -> String?
}

enum AuthState {
    case login
    case signup
}

@Observable
class AuthViewModelImpl: AuthViewModel {
    private let provider: AuthProvider

    var loginData: LoginData = .empty
    var signupData: SignupData = .empty
    var state: AuthState = .signup
    
    let onSuccess: () -> Void
    
    init(provider: AuthProvider, onSuccess: @escaping () -> Void) {
        self.provider = provider
        self.onSuccess = onSuccess
    }
    
    func login() {
        Task {
            let success = await provider.login(data: loginData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                if success {
                    ToastManager.shared.show(
                        message: Captions.welcome
                    )
                    
                    onSuccess()
                } else {
                    ToastManager.shared.show(
                        message: Captions.loggingError,
                        type: .error
                    )
                }
            }
        }
    }
    
    func validatePassword() -> String? {
        if signupData.password != signupData.passwordConfirmation {
            return "Пароли не совпадают"
        }
        
        return nil
    }
    
    func validateEmail() -> String? {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: signupData.email) {
            return "Неверный формат почты"
        }
        
        return nil
    }
    
    func register() {
        Task {
            let success = await provider.signup(data: signupData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                if success {
                    state = .login
                } else {
                    ToastManager.shared.show(
                        message: Captions.registerError,
                        type: .error
                    )
                }
            }
        }
    }
}
