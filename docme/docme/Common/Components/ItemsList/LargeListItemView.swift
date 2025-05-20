import Foundation
import SwiftUI


struct LargeListItemView<BottomView: View>: View {
    @Environment(\.theme) var theme
    
    enum TrailingView {
        case empty
        case toggle(value: Binding<Bool>)
    }
    
    let title: String
    let trailingView: TrailingView?
    let bottomView: () -> BottomView
    
    init(
        title: String,
        trailingView: TrailingView? = nil,
        bottomView: @escaping () -> BottomView = { EmptyView() }
    ) {
        self.title = title
        self.trailingView = trailingView
        self.bottomView = bottomView
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m6) {
            HStack {
                HStack(spacing: DS.Spacing.m2) {
                    Text(title)
                        .applyFont(.body(.md, .bold))
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(1)
                }
                
                Spacer()
                
                trailingViewContent
            }
            
            bottomView()
        }
        .padding(.vertical, DS.Spacing.m4)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var trailingViewContent: some View {
        if let trailingView {
            switch trailingView {
            case .empty: EmptyView()
            case .toggle(let value):
                Toggle(isOn: value) {}
                    .labelsHidden()
            }
        }
    }
}

#Preview {
    VStack {
        LargeListItemView(title: "123", trailingView: .toggle(value: .constant(true)))
    }
}
