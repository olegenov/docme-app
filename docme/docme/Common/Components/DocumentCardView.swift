import Foundation
import SwiftUI


struct DocumentCardView: View {
    @Environment(\.theme) var theme
    
    enum DisplayMode {
        case sm
        case md(imageUrl: String)
        case lg(imageUrl: String, date: Date)
    }
    
    enum LeadingView {
        case icon(ImageIcon.Name, Color)
        case tag(TagsView.TagColor)
    }
    
    let configuration: DisplayMode
    let leadingView: LeadingView
    let title: String
    let isFavorite: Bool
    let imageManager: ImageManager
    
    var onFavoriteTap: (() -> Void)? = nil
    
    @State private var image: UIImage = UIImage()
    
    var body: some View {
        VStack {
            switch configuration {
            case .sm:
                smallView
            case .md(let imageUrl):
                mediumView(imageUrl: imageUrl)
            case .lg(let imageUrl, let date):
                largeView(imageUrl: imageUrl, date: date)
            }
        }
        .background(theme.colors.overlay)
        .cornerRadius(DS.Rounding.m8)
        .applyShadow(theme.shadows.overlayShadow)
    }
    
    private var headerView: some View {
        HStack(spacing: DS.Spacing.m4) {
            leadingViewContent
            
            Text(title)
                .applyFont(.body(.sm, .bold))
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private var leadingViewContent: some View {
        switch leadingView {
        case .icon(let name, let color):
            ImageIcon(
                name: name,
                size: .md,
                color: color
            )
        case .tag(let color):
            TagsView(colors: [color])
        }
    }
    
    private var favoriteView: some View {
        ImageIcon(
            name: isFavorite ? .starFilled : .starOutline,
            size: .sm
        )
            .onTapGesture {
                onFavoriteTap?()
            }
    }
    
    private var smallView: some View {
        headerView
            .padding(.vertical, DS.Spacing.m6)
            .padding(.horizontal, DS.Spacing.m8)
    }
    
    private func imageView(imageUrl: String, ratio: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                theme.colors.overlay
                ActivityIndicatorView(size: .md)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width * ratio
                    )
                    .clipped()
            }
        }
        .aspectRatio(1 / (ratio != 0 ? ratio : 1), contentMode: .fit)
        .cornerRadius(DS.Rounding.m4)
        .onAppear {
            Task {
                image = await imageManager.loadImage(from: imageUrl)
            }
        }
    }
    
    private func mediumView(imageUrl: String) -> some View {
        VStack(spacing: 0) {
            imageView(imageUrl: imageUrl, ratio: 2/3)
                .padding(.horizontal, DS.Spacing.m4)
                .padding(.top, DS.Spacing.m4)
            
            HStack {
                headerView
                
                Spacer()
                
                favoriteView
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.m6)
        }
    }
    
    private func largeView(
        imageUrl: String,
        date: Date
    ) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.m8) {
            imageView(imageUrl: imageUrl, ratio: 9/16)
            
            VStack(alignment: .leading) {
                headerView
                
                Text(date.formatted(style: .ddMMyyyy))
                    .applyFont(.body(DSFontSize.sm, .regular))
                    .foregroundStyle(theme.colors.textSecondary)
            }
            
            Spacer()
            
            favoriteView
        }
        .padding(DS.Spacing.m4)
        .frame(height: DS.Size.m32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        DocumentCardView(
            configuration: .sm,
            leadingView: .icon(.governmentOutline, .red),
            title: "123123",
            isFavorite: true,
            imageManager: DefaultImageManager.shared
        )
        
        DocumentCardView(
            configuration: .md(imageUrl: "https://i.pinimg.com/originals/62/f3/a3/62f3a39cfdbc521cdfabdf1757a9026e.jpg"),
            leadingView: .icon(.driverOutline, .cyan),
            title: "123123",
            isFavorite: true,
            imageManager: DefaultImageManager.shared
        ).frame(maxWidth: 200)
        
        DocumentCardView(
            configuration: .lg(imageUrl: "https://i.pinimg.com/originals/62/f3/a3/62f3a39cfdbc521cdfabdf1757a9026e.jpg", date: .now),
            leadingView: .tag(.red),
            title: "123123",
            isFavorite: true,
            imageManager: DefaultImageManager.shared
        )
    }
}
