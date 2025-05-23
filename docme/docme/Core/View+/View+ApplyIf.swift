import Foundation
import SwiftUI


extension View {
    @ViewBuilder
    func applyIf(
        _ condition: Bool,
        transform: (Self) -> some View
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
