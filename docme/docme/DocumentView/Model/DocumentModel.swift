import Foundation
import UIKit


struct DocumentModel: Equatable {
    let title: String
    let description: String?
    let image: UIImage?
    let type: DocumentCard.Icon
    let color: DocumentCard.Color
}
