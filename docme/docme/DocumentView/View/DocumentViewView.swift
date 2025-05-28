import Foundation
import SwiftUI


struct DocumentViewView<ViewModel: DocumentViewViewModel>: View {
    @Environment(\.theme) var theme
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                imageView
                
                mainInfoView
                
                if viewModel.fields.isNotEmpty {
                    fieldsView
                }
            }.padding(.horizontal, DS.Spacing.m8)
        }
        .task {
            await viewModel.loadData()
        }
        .overlay {
            if viewModel.showLoading {
                showLoading
            }
        }
        .animation(.easeInOut, value: viewModel.document)
    }
    
    private var tabbarView: some View {
        DocumentViewTabbarView(
            onCloseTap: viewModel.closePage,
            onEditTap: viewModel.editDocument,
            onShareTap: viewModel.shareDocument
        ).padding(.horizontal, DS.Spacing.m8)
    }
    
    private var imageView: some View {
        DocumentImageView(
            image: viewModel.document?.image
        )
    }
    
    private var mainInfoView: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m4) {
            if let document = viewModel.document {
                HStack(spacing: DS.Spacing.m4) {
                    leadingView(model: document)

                    TitleView(
                        text: document.title
                    )
                }
                
                if let description = document.description {
                    DescriptionView(
                        text: description
                    )
                }
            } else {
                TitleView(
                    text: Captions.loadingDocument
                )
            }
        }
    }
    
    private var fieldsView: some View {
        ItemsListView {
            ForEach(Array(viewModel.fields.enumerated()), id: \.element.id) { index, field in
                ListItemView(
                    configuration: .defaultStyle(
                        title: field.name,
                        leadingView: .empty
                    ),
                    trailingText: field.value,
                    trailingView: .copy(
                        action: { viewModel.copyField(field) }
                    )
                )
                
                if index < viewModel.fields.count - 1 {
                    SeparatorView()
                }
            }
        }
    }

    private var showLoading: some View {
        ZStack {
            theme.colors.overlay
                .ignoresSafeArea()
            
            ActivityIndicatorView(size: .md)
        }
    }
    
    private func leadingView(model: DocumentModel) -> some View {
        if model.type != .tag {
            FabView(
                content: .icon(
                    .init(
                        name: model.type.toTagIconName(),
                        size: .md,
                        color: model.color.toIconColor()
                    )
                )
            )
        } else {
            FabView(
                content: .tags(selectedTags: [model.color.toTagColor()])
            )
        }
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
