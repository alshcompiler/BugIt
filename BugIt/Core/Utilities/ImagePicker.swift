import PhotosUI
import SwiftUI

// ImagePicker helper to handle image selection
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: ImageSourceType
    var onImagePicked: (UIImage) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
            let parent: ImagePicker

            init(parent: ImagePicker) {
                self.parent = parent
            }

            // UIImagePickerController delegate methods
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let image = info[.originalImage] as? UIImage {
                    parent.onImagePicked(image)
                }
                picker.dismiss(animated: true)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }

            // PHPickerViewController delegate methods
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)

                guard let result = results.first else { return }

                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let self = self else { return }
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.onImagePicked(image)
                            }
                        }
                    }
                }
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> UIViewController {
            switch sourceType {
            case .camera:
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = context.coordinator
                return picker
            case .photoLibrary:
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = context.coordinator
                return picker
            }
        }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

enum ImageSourceType {
    case camera
    case photoLibrary
}
