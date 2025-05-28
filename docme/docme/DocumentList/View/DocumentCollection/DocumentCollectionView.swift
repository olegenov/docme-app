import Foundation
import SwiftUI


struct DocumentCollectionView: View {
    let documents: [DocumentCard]
    let imageService: ImageService
    
    var onFavoriteToggle: ((DocumentCard) -> Void)? = nil
    var onDocumentTap: ((DocumentCard) -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.m4) {
            VStack(alignment: .leading, spacing: DS.Spacing.m4) {
                ForEach(leftColumnItems, id: \.self) { document in
                    DocumentCollectionItemView(
                        displayType: .collection,
                        document: document,
                        imageService: imageService,
                        onFavoriteToggle: onFavoriteToggle,
                        onDocumentTap: onDocumentTap
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: DS.Spacing.m4) {
                ForEach(rightColumnItems, id: \.self) { document in
                    DocumentCollectionItemView(
                        displayType: .collection,
                        document: document,
                        imageService: imageService,
                        onFavoriteToggle: onFavoriteToggle,
                        onDocumentTap: onDocumentTap
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var leftColumnItems: [DocumentCard] {
        documents.enumerated().compactMap { index, element in
            index % 2 == 0 ? element : nil
        }
    }

    private var rightColumnItems: [DocumentCard] {
        documents.enumerated().compactMap { index, element in
            index % 2 != 0 ? element : nil
        }
    }
}
