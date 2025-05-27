import SwiftUI
import PhotosUI


struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, selectedImage: $selectedImage)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if isPresented {
                let picker = PHPickerViewController(configuration: makeConfiguration())
                picker.delegate = context.coordinator
                controller.present(picker, animated: true)
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let picker = PHPickerViewController(configuration: makeConfiguration())
            picker.delegate = context.coordinator
            uiViewController.present(picker, animated: true)
        }
    }

    private func makeConfiguration() -> PHPickerConfiguration {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        @Binding var isPresented: Bool
        @Binding var selectedImage: UIImage?

        init(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>) {
            _isPresented = isPresented
            _selectedImage = selectedImage
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            isPresented = false

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.selectedImage = image as? UIImage
                }
            }
        }
    }
}
