struct SignupData {
    var username: String
    var name: String
    var email: String
    var password: String
    var passwordConfirmation: String
    
    static var empty: SignupData {
        SignupData(username: "", name: "", email: "", password: "", passwordConfirmation: "")
    }
}
