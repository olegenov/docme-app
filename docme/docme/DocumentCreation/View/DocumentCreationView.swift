import Foundation
import SwiftUI
import PhotosUI


struct DocumentCreationView<ViewModel: DocumentCreationViewModel>: View {
    @Environment(\.theme) var theme
    
    @StateObject var viewModel: ViewModel
    
    @State private var showImagePicker: Bool = false
    @State private var showCancelCreationAlert: Bool = false
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                imageView
                
                mainInfoView
                
                documentTypeList
                
                documentColorList
            }.padding(.horizontal, DS.Spacing.m8)
        }
        .hideKeyboardOnDrag()
        .onAppear {
            showImagePicker = true
        }
        .onDisappear {
            DocumentListEventBus.shared.send(.documentCreationClosed)
        }
        .background(
             imagePicker
        )
        .animation(.easeInOut, value: viewModel.documentIcon)
        .animation(.easeInOut, value: viewModel.documentColor)
        .animation(.easeInOut, value: viewModel.showLoading)
        .overlay {
            if viewModel.showLoading {
                showLoading
            }
        }
        .cancelCreationAlert(
            isPresented: $showCancelCreationAlert,
            onContinue: {
                showCancelCreationAlert = false
                viewModel.cancelDocumentCreation()
            },
            onCancel: {
                showCancelCreationAlert = false
            }
        )
    }
    
    private var tabbarView: some View {
        DocumentCreationTabbarView(
            onCloseTap: {
                showCancelCreationAlert = true
            },
            onCreateTap: viewModel.createDocument
        ).padding(.horizontal, DS.Spacing.m8)
    }
    
    private var imageView: some View {
        DocumentImageEdit(
            image: $viewModel.documentImage,
            onAddImageTap: {
                showImagePicker = true
            }
        )
    }
    
    private var mainInfoView: some View {
        VStack(spacing: DS.Spacing.m4) {
            TitleView(
                editing: $viewModel.documentTitle,
                placeholder: Captions.newDocument
            )
            DescriptionView(
                editing: $viewModel.documentDescription,
                placeholder: Captions.description
            )
        }
    }
    
    @ViewBuilder
    private var documentTypeList: some View {
        let itemsFirstRow: [TypeListData] = [
            .init(icon: .passport, title: Captions.passport),
            .init(icon: .government, title: Captions.snils),
            .init(icon: .tag, title: Captions.another)
        ]
        
        let itemsSecondRow: [TypeListData] = [
            .init(icon: .international, title: Captions.internationalPassport),
            .init(icon: .driver, title: Captions.driverLicense)
        ]
        
        VStack(alignment: .leading, spacing: DS.Spacing.m8) {
            TitleSecondaryView(text: Captions.documentType)
            VStack(alignment: .leading, spacing: DS.Spacing.m4) {
                HStack(spacing: DS.Spacing.m4) {
                    ForEach(itemsFirstRow, id: \.self) { item in
                        FabView(
                            content: .iconText(
                                .init(name: item.icon.toTagIconName(), size: .md),
                                item.title
                            ),
                            isSelected: viewModel.documentIcon == item.icon,
                            onTapAction: {
                                viewModel.documentIcon = item.icon
                            }
                        )
                    }
                }
                HStack(spacing: DS.Spacing.m4) {
                    ForEach(itemsSecondRow, id: \.self) { item in
                        FabView(
                            content: .iconText(
                                .init(name: item.icon.toTagIconName(), size: .md),
                                item.title
                            ),
                            isSelected: viewModel.documentIcon == item.icon,
                            onTapAction: {
                                viewModel.documentIcon = item.icon
                            }
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var documentColorList: some View {
        let items: [DocumentCardUI.Color] = [
            .none,
            .red,
            .green,
            .yellow
        ]
        
        VStack(alignment: .leading, spacing: DS.Spacing.m8) {
            TitleSecondaryView(text: Captions.documentColor)
            
            HStack(spacing: DS.Spacing.m4) {
                ForEach(items, id: \.self) { item in
                    FabView(
                        content: .tags(selectedTags: [item.toTagColor()]),
                        isSelected: viewModel.documentColor == item,
                        onTapAction: {
                            viewModel.documentColor = item
                        }
                    )
                }
            }
        }
    }
    
    private var imagePicker: some View {
        PhotoPicker(
            isPresented: $showImagePicker,
            selectedImage: $viewModel.documentImage
        )
    }
    
    private var showLoading: some View {
        ZStack {
            theme.colors.overlay
                .ignoresSafeArea()
            
            ActivityIndicatorView(size: .md)
        }
    }
}


struct TypeListData: Hashable {
    let icon: DocumentCardUI.Icon
    let title: String
}


private struct CancelCreationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let onContinue: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Captions.cancelDocumentAlertTitle,
                isPresented: $isPresented
            ) {
                Button(Captions.yes, role: .destructive) {
                    onContinue()
                }
                Button(Captions.no, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(Captions.cancelDocumentAlertDescription)
            }
    }
}


private extension View {
    func cancelCreationAlert(
        isPresented: Binding<Bool>,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(CancelCreationAlertModifier(
            isPresented: isPresented,
            onContinue: onContinue,
            onCancel: onCancel
        ))
    }
}
