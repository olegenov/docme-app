import Foundation
import SwiftUI


extension DocumentListTabbarView {
    struct SearchView: View {
        let onSearchClear: () -> Void
        let onSearchClose: () -> Void
        let onSearchChange: (String) -> Void
        
        @State private var searchText: String = ""
        @State private var isClearingVisible: Bool = false
        
        var body: some View {
            HStack {
                FabView(
                    content: .icon(
                        .init(name: .chevronLeftOutline, size: .md)
                    ),
                    longPaddings: true
                ) {
                    searchText = ""
                    onSearchClose()
                }
                
                InputFieldView(
                    placeholder: Captions.searchDocs,
                    text: $searchText
                )
                
                if isClearingVisible {
                    FabView(
                        content: .icon(
                            .init(name: .crossOutline, size: .md)
                        )
                    ) {
                        searchText = ""
                        onSearchClear()
                    }
                }
            }
            .onChange(of: searchText) {
                isClearingVisible = searchText.isNotEmpty
                
                if searchText.isEmpty {
                    onSearchClear()
                    return
                }
                
                onSearchChange(searchText)
            }
            .animation(.easeInOut, value: isClearingVisible)
        }
    }
}
