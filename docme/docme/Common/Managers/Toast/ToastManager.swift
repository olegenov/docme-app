import Combine
import SwiftUI

final class ToastManager: ObservableObject {
    struct ToastData: Identifiable, Equatable {
        let id = UUID()
        let message: String
        let type: ToastType
        let duration: TimeInterval
    }

    enum ToastType {
        case success, error
    }
    
    static let shared = ToastManager()

    @Published var toast: ToastData?

    private init() {}

    func show(message: String, type: ToastType = .success, duration: TimeInterval = 2.0) {
        toast = ToastData(message: message, type: type, duration: duration)
    }
    
    func dismissToast(_ toast: ToastData) {
        if self.toast == toast {
            self.toast = nil
        }
    }
}
