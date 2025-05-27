import Foundation
import SwiftUI


struct DocumentImageView: View {
    @Environment(\.theme) var theme
    
    @Binding var image: UIImage?
    
    var onAddImageTap: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(DS.Rounding.m4)
            } else {
                ActivityIndicatorView(size: .md)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 150)
        .overlay(alignment: .bottomTrailing) {
            if let onAddImageTap {
                FabView(
                    content: .icon(.init(name: .editOutline, size: .md)),
                    onTapAction: onAddImageTap
                )
            }
        }
        .padding(DS.Spacing.m4)
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
}
