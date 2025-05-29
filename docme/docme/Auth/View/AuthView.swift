import Foundation
import SwiftUI


struct AuthView<ViewModel: AuthViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    @State private var passwordError: String? = nil
    @State private var emailError: String? = nil
    
    var body: some View {
        MainContent(alignment: .center) {
            tabbar

            switch viewModel.state {
            case .login: loginForm
            case .signup: signupForm
            }
        }.animation(.easeInOut, value: viewModel.state)
    }
    
    @ViewBuilder
    private var tabbar: some View {
        switch viewModel.state {
        case .login:
            FabView(
                content: .text(Captions.signup),
                onTapAction: {
                    viewModel.state = .signup
                }
            )
        case .signup:
            FabView(
                content: .text(Captions.login),
                onTapAction: {
                    viewModel.state = .login
                }
            )
        }
    }
    
    private var loginForm: some View {
        VStack(alignment: .center, spacing: DS.Spacing.m8) {
            TitleView(text: Captions.login)
            
            VStack(spacing: DS.Spacing.m4) {
                InputFieldView(
                    placeholder: Captions.username,
                    text: $viewModel.loginData.username
                ).frame(maxWidth: 267)
                
                InputFieldView(
                    placeholder: Captions.password,
                    text: $viewModel.loginData.password
                ).frame(maxWidth: 267)
            }
            
            DSButton(
                text: Captions.loginButtonTitle,
                onTap: viewModel.login,
                maxWidth: true
            ).frame(maxWidth: 267)
        }
    }
    
    @ViewBuilder
    private var signupForm: some View {
        VStack(alignment: .center, spacing: DS.Spacing.m8) {
            TitleView(text: Captions.signup)
            
            VStack(spacing: DS.Spacing.m4) {
                InputFieldView(
                    placeholder: Captions.username,
                    text: $viewModel.signupData.username
                ).frame(maxWidth: 267)
                
                InputFieldView(
                    placeholder: Captions.name,
                    text: $viewModel.signupData.name
                ).frame(maxWidth: 267)
                
                InputFieldView(
                    placeholder: Captions.email,
                    text: $viewModel.signupData.email
                ).frame(maxWidth: 267)
                
                if let emailError {
                    Text(emailError)
                        .applyFont(.body(.sm, .regular))
                }
                
                InputFieldView(
                    placeholder: Captions.password,
                    text: $viewModel.signupData.password
                ).frame(maxWidth: 267)
                
                if let passwordError {
                    Text(passwordError)
                        .applyFont(.body(.sm, .regular))
                }
                
                InputFieldView(
                    placeholder: Captions.confirmPassword,
                    text: $viewModel.signupData.passwordConfirmation
                ).frame(maxWidth: 267)
            }
            
            DSButton(
                text: Captions.registerButtonTitle,
                onTap: viewModel.register,
                maxWidth: true
            ).frame(maxWidth: 267)
        }
        .onChange(of: viewModel.signupData.password) {
            passwordError = viewModel.validatePassword()
        }
        .onChange(of: viewModel.signupData.passwordConfirmation) {
            passwordError = viewModel.validatePassword()
        }
        .onChange(of: viewModel.signupData.email) {
            emailError = viewModel.validateEmail()
        }
    }
}
