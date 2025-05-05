import Foundation

extension Date {
    enum CutomFormatStyle: String {
        case ddMMyyyy = "dd.MM.yyyy"
    }
    
    func formatted(style: CutomFormatStyle) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = style.rawValue
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter.string(from: self)
    }
}
