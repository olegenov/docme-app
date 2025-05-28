import Foundation
import SwiftUI
import PhotosUI


struct DocumentScreenView<ViewModel: DocumentScreenViewModel>: View {
    @Environment(\.theme) var theme
    
    @StateObject var viewModel: ViewModel
    
    @State private var showImagePicker: Bool = false
    @State private var showCancelCreationAlert: Bool = false
    @State private var showCancelEditAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        MainContent {
            tabbarView
            
            MainScrollView {
                imageView
                
                mainInfoView
                
                if viewModel.editMode == .viewing {
                    if viewModel.fields.filter({ !$0.isEmpty }).isNotEmpty {
                        fieldsView
                    }
                } else if viewModel.editMode == .editing {
                    documentTypeList
                    
                    documentColorList
                    
                    fieldsEditView
                        .padding(.bottom, 300)
                } else {
                    documentTypeList
                    
                    documentColorList
                }
            }
            .padding(.horizontal, DS.Spacing.m8)
        }
        .hideKeyboardOnDrag()
        .task {
            if viewModel.editMode != .creation {
                await viewModel.loadData()
            }
        }
        .onAppear {
            DocumentListEventBus.shared.send(.documentOpened)
            
            if viewModel.editMode == .creation {
                showImagePicker = true
            }
        }
        .onDisappear() {
            DocumentListEventBus.shared.send(.documentClosed)
        }
        .background(
             imagePicker
        )
        .animation(.easeInOut, value: viewModel.document.icon)
        .animation(.easeInOut, value: viewModel.document.color)
        .animation(.easeInOut, value: viewModel.fields)
        .animation(.easeInOut, value: viewModel.editMode)
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
                viewModel.closePage()
            },
            onCancel: {
                showCancelCreationAlert = false
            }
        )
        .cancelEditAlert(
            isPresented: $showCancelEditAlert,
            onContinue: {
                showCancelEditAlert = false
                viewModel.cancelDocumentEdit()
            },
            onCancel: {
                showCancelEditAlert = false
            }
        )
        .deleteAlert(
            isPresented: $showDeleteAlert,
            onContinue: {
                showDeleteAlert = false
                viewModel.deleteDocument()
            },
            onCancel: {
                showDeleteAlert = false
            }
        )
    }
    
    private var tabbarView: some View {
        Group {
            switch viewModel.editMode {
            case .creation:
                DocumentCreationTabbarView(
                    onCloseTap: {
                        showCancelCreationAlert = true
                    },
                    onCreateTap: viewModel.createDocument
                )
            case .editing:
                DocumentEditTabbarView(
                    onCloseTap: {
                        showCancelEditAlert = true
                    },
                    onDeleteTap: viewModel.deleteDocument,
                    onSaveTap: viewModel.saveDocument
                )
            case .viewing:
                DocumentViewTabbarView(
                    onCloseTap: viewModel.closePage,
                    onEditTap: viewModel.editDocument,
                    onShareTap: viewModel.shareDocument
                )
            }
        }.padding(.horizontal, DS.Spacing.m8)
    }
    
    @ViewBuilder
    private var imageView: some View {
        let openPickerAction: (() -> Void)? = switch viewModel.editMode {
        case .creation: {
            showImagePicker = true
        }
        case .viewing, .editing: nil
        }
        
        DocumentImageEdit(
            image: $viewModel.document.image,
            onAddImageTap: openPickerAction
        )
    }
    
    private var mainInfoView: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m4) {
            switch viewModel.editMode {
            case .creation, .editing:
                TitleView(
                    editing: $viewModel.document.title,
                    placeholder: Captions.newDocument
                )
                DescriptionView(
                    editing: $viewModel.document.description,
                    placeholder: Captions.description
                )
            case .viewing:
                HStack(spacing: DS.Spacing.m4) {
                    leadingView(model: viewModel.document)

                    TitleView(
                        text: viewModel.document.title
                    )
                }
                
                if viewModel.document.description.isNotEmpty {
                    DescriptionView(
                        text: viewModel.document.description
                    )
                }
            }
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
                        tagFab(data: item)
                    }
                }
                HStack(spacing: DS.Spacing.m4) {
                    ForEach(itemsSecondRow, id: \.self) { item in
                        tagFab(data: item)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var documentColorList: some View {
        let items: [DocumentScreen.Color] = [
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
                        isSelected: viewModel.document.color == item,
                        onTapAction: {
                            viewModel.document.color = item
                        }
                    )
                }
            }
        }
    }
    
    private var imagePicker: some View {
        PhotoPicker(
            isPresented: $showImagePicker,
            selectedImage: $viewModel.document.image
        )
    }
    
    @ViewBuilder
    private var fieldsView: some View {
        let fields = viewModel.fields.filter { !$0.isEmpty }
        
        ItemsListView {
            ForEach(
                Array(fields.enumerated()),
                id: \.element.id
            ) { index, field in
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
                
                if index < fields.count - 1 {
                    SeparatorView()
                }
            }
        }
    }
    
    private var fieldsEditView: some View {
        ItemsListView {
            ForEach(Array(viewModel.fields.enumerated()), id: \.element.id) { index, field in
                let binding = Binding<DocumentScreenField>(
                    get: { viewModel.fields[index] },
                    set: { viewModel.fields[index] = $0 }
                )
                    
                ListItemView(
                    configuration: .fullEditing(
                        placeholder: Captions.field,
                        title: binding.name,
                        placeholderSecondary: Captions.newFieldValue,
                        secondary: binding.value
                    ),
                    trailingView: field.name.isEmpty && field.value.isEmpty ? .empty :
                            .cross(
                                action: {
                                    viewModel.deleteField(field)
                                }
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
    
    private func tagFab(data: TypeListData) -> some View {
        FabView(
            content: .iconText(
                .init(name: data.icon.toTagIconName(), size: .md),
                data.title
            ),
            isSelected: viewModel.document.icon == data.icon,
            onTapAction: {
                viewModel.document.icon = data.icon
            }
        )
    }
    
    private func leadingView(model: DocumentScreen) -> some View {
        if model.icon != .tag {
            FabView(
                content: .icon(
                    .init(
                        name: model.icon.toTagIconName(),
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


struct TypeListData: Hashable {
    let icon: DocumentScreen.Icon
    let title: String
}


private struct CancelCreationAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let onContinue: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Captions.cancelDocumentCreationAlertTitle,
                isPresented: $isPresented
            ) {
                Button(Captions.yes, role: .destructive) {
                    onContinue()
                }
                Button(Captions.no, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(Captions.cancelDocumentCreationAlertDescription)
            }
    }
}


private struct CancelEditAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let onContinue: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Captions.cancelDocumentEditAlertTitle,
                isPresented: $isPresented
            ) {
                Button(Captions.yes, role: .destructive) {
                    onContinue()
                }
                Button(Captions.no, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(Captions.cancelDocumentEditAlertDescription)
            }
    }
}


private struct DeleteAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let onContinue: () -> Void
    let onCancel: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(
                Captions.documentDeleteAlertTitle,
                isPresented: $isPresented
            ) {
                Button(Captions.yes, role: .destructive) {
                    onContinue()
                }
                Button(Captions.no, role: .cancel) {
                    onCancel()
                }
            } message: {
                Text(Captions.documentDeleteAlertDescription)
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
    
    func cancelEditAlert(
        isPresented: Binding<Bool>,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(CancelEditAlertModifier(
            isPresented: isPresented,
            onContinue: onContinue,
            onCancel: onCancel
        ))
    }
    
    func deleteAlert(
        isPresented: Binding<Bool>,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(CancelEditAlertModifier(
            isPresented: isPresented,
            onContinue: onContinue,
            onCancel: onCancel
        ))
    }
}

private extension DocumentScreen.Color {
    func toIconColor() -> Color {
        switch self {
        case .none: DS.theme.colors.outline
        case .green: DS.theme.colors.brandCyan
        case .red: DS.theme.colors.brandMagenta
        case .yellow: DS.theme.colors.brandGreen
        }
    }
}
