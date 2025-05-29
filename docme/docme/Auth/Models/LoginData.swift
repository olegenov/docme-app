struct LoginData {
    var username: String
    var password: String
    
    static var empty: LoginData {
        LoginData(username: "", password: "")
    }
}
