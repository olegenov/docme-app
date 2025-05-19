import Foundation
import SwiftUI


struct DocumentCollectionItemView: View {
    enum DisplayType {
        case collection
        case list
        case favorite
    }
    
    let displayType: DisplayType
    let document: DocumentCardUI
    let imageService: ImageService
    
    var onFavoriteToggle: ((DocumentCardUI) -> Void)? = nil
    
    var body: some View {
        DocumentCardView(
            configuration: configuration,
            leadingView: documentIcon,
            title: document.title,
            isFavorite: document.isFavorite,
            imageService: imageService,
            onFavoriteTap: {
                withAnimation {
                    onFavoriteToggle?(document)
                }
            }
        )
    }
    
    private var configuration: DocumentCardView.DisplayMode {
        switch displayType {
        case .collection: .md(imageUrl: document.imageUrl)
        case .list: .lg(imageUrl: document.imageUrl, date: document.createdAt)
        case .favorite: .sm
        }
    }
    
    private var documentIcon: DocumentCardView.LeadingView {
        guard let iconName = document.icon.toTagIconName() else {
            return .tag(document.color.toTagColor())
        }
        
        return .icon(
            iconName,
            document.color.toIconColor()
        )
    }
}

private extension DocumentCardUI.Color {
    func toIconColor() -> Color {
        switch self {
        case .none: DS.theme.colors.outline
        case .green: DS.theme.colors.brandCyan
        case .red: DS.theme.colors.brandMagenta
        case .yellow: DS.theme.colors.brandGreen
        }
    }
}
