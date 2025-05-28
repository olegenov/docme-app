import Foundation


extension Collection {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
