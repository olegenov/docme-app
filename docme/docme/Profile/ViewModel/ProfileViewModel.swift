import Foundation


protocol ProfileViewModel: ObservableObject, AnyObject {

}

class ProfileViewModelImpl: ProfileViewModel {
    private let provider: ProfileProvider
    private let router = Router.shared

    init(provider: ProfileProvider) {
        self.provider = provider
    }
}
