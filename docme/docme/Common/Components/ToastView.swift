import SwiftUI

struct ToastView: View {
    @Environment(\.theme) var theme
    @ObservedObject var toastManager = ToastManager.shared

    let toast: ToastManager.ToastData

    @State private var isVisible = false

    var body: some View {
        FabView(
            content: .text(toast.message),
            background: backgroundColor,
            longPaddings: true
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? DS.Spacing.m8 : 0)
        .onAppear {
            withAnimation {
                isVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                withAnimation {
                    isVisible = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    toastManager.dismissToast(toast)
                }
            }
        }
    }

    private var backgroundColor: Color {
        switch toast.type {
        case .success:
            return theme.colors.brandCyan
        case .error:
            return theme.colors.brandMagenta
        }
    }
}
