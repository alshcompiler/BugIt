import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    @StateObject var viewModel: ReportBugViewModel

    @Environment(\.isSignedIn) var isSignedIn

    @State private var descryptionTextField: String = ""
    @FocusState private var isTextEditorFocused: Bool

    @State private var items: [Item] = []
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var window: UIWindow?
    @State private var showAlert = false
    @State private var alertContent: AlertContet?

    private enum Constants {
        static let maxImageCount = 5
        static let cornerRadius = 10.0
        static let smallPadding = 8.0
        static let largePadding = 20.0
        static let textEditorHeight = 120.0
        static let gridItemDimention = 100.0
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var attachedScreenshotsTitle: String {
        "- Bug Screenshots \(items.count) / \(Constants.maxImageCount)"
    }

    private var isSubmitEnabled: Bool {
        !descryptionTextField.isEmpty && !items.isEmpty
    }

    var body: some View {
        VStack {

            if isSignedIn {
                Text("Report a bug")
                    .font(.title)
                    .bold()
                    .padding(.vertical, Constants.largePadding)

                VStack {
                    Text(String.bugDescriptionPlaceholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Constants.smallPadding)
                    TextEditor(text: $descryptionTextField)
                        .padding(Constants.smallPadding)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                        .frame(height: Constants.textEditorHeight)
                        .padding(.vertical)

                    Text(attachedScreenshotsTitle)
                        .foregroundStyle(items.isEmpty ? .red : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Constants.smallPadding)

                    LazyVGrid(columns: columns, spacing: Constants.largePadding) {
                        ForEach(items.indices, id: \.self) { index in
                            imageItem(index)
                        }

                        // Add Button
                        if items.count < 5 {
                            addImageButton()
                        }
                    }
                    .padding()

                    Button(action: {
                        submitBug()
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSubmitEnabled ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(Constants.cornerRadius)
                    }
                    .disabled(!isSubmitEnabled) // Disable button if fields are empty
                    .padding()
                }
                .padding()
            }
            else {
                SignInView(handleSignInButton: handleSignInButton)
            }
        }
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                self.window = windowScene.windows.first
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .focused($isTextEditorFocused)
        .onTapGesture {
            isTextEditorFocused = false
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isTextEditorFocused = false
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                addItem(image)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertContent?.title ?? ""),
                  message: Text(alertContent?.description ?? ""),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func submitBug() {
        Task {
            await viewModel.reportBug(description: "we need help",
                                      images: items.imagesData)
        }
    }
}


private extension ContentView {
    func captureScreenshot() {
            // Dismiss the action sheet before taking the screenshot
            self.window?.rootViewController?.dismiss(animated: true, completion: {
                guard let window = self.window else { return }
                UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                if let screenshot = image {
                    addItem(screenshot)
                }
            })
        }

    func addImageButton() -> some View {
        Button(action: showImagePickerOptions) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.gridItemDimention,
                       height: Constants.gridItemDimention)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(Constants.cornerRadius)
        }
    }

    func imageItem(_ index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: items[index].image)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.gridItemDimention,
                       height: Constants.gridItemDimention)
                .cornerRadius(Constants.cornerRadius)
                .clipped()

            Button(action: {
                removeItem(at: index)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .padding(Constants.smallPadding)
            }
        }
    }

    func addItem(_ image: UIImage) {
        guard items.count < Constants.maxImageCount else {
            alertContent = .maxImagesSelected
            showAlert = true
            return
        }
        items.append(.init(image: image))
    }

    func removeItem(at index: Int) {
        items.remove(at: index)
    }

    func showImagePickerOptions() {
        let actionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.sourceType = .camera
            self.showingImagePicker = true
        })

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.sourceType = .photoLibrary
            self.showingImagePicker = true
        })

        actionSheet.addAction(UIAlertAction(title: "Screenshot", style: .default) { _ in
            self.captureScreenshot()
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(actionSheet, animated: true)
        }
    }

    func handleSignInButton() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                                              as? UIWindowScene)?.windows.first?.rootViewController
        else {return}
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/spreadsheets"]
        ) { signInResult, error in
            if let result = signInResult {
                // Inspect error
                alertContent = .loginFailure
                showAlert = true
            }
        }
    }
}

private extension String {
    static let bugDescriptionPlaceholder = "- Bug Description"
}

private struct AlertContet {
    let title: String
    let description: String
}

private extension AlertContet {
    static let maxImagesSelected: Self = .init(title: "Maximum Images Selected",
                                               description: "You can only add up to 5 images.")
    static let loginFailure: Self = .init(title: "Login Error",
                                               description: "Please try again")
}

#Preview {
    ContentView(viewModel: ReportBugViewModel(bugService: GoogleSheetsService(httpClient: URLSessionHTTPClient())))
        .environment(\.isSignedIn, true)
}

// ImagePicker helper to handle image selection
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

private extension [Item] {
    static let maxImageSizeInKB = 2000
    var imagesData: [Data] {
        compactMap { $0.image.compressTo(maxSizeInKB: Self.maxImageSizeInKB) }
    }
}

private struct Item: Identifiable {
    let id = UUID()
    let image: UIImage
}
