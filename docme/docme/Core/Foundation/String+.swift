import Foundation


extension String {
    func firstLetterCapitalized() -> String {
        guard let firstCharacter = first else {
            return self
        }
        
        return String(firstCharacter).uppercased() + dropFirst()
    }
}
