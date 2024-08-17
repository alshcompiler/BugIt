//
//  ContentView.swift
//  BugIt
//
//  Created by Mostafa Sultan on 10/08/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    @StateObject var viewModel: ReportBugViewModel

    @Environment(\.isSignedIn) var isSignedIn

    @State private var descryptionTextField: String = ""
    @FocusState private var isTextEditorFocused: Bool

    var isSubmitEnabled: Bool {
        !descryptionTextField.isEmpty
    }

    var body: some View {
        VStack {

            if isSignedIn {
                Text("Report a bug")
                    .font(.title)
                    .bold()
                    .padding(.vertical, 20)

                VStack {
                    Text(String.bugDescriptionPlaceholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                    TextEditor(text: $descryptionTextField)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 120)
                        .padding(.vertical)

                    

                    Button(action: {
                        submitBug()
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSubmitEnabled ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
        }.frame(alignment: .leading)
    }

    private enum Constants {
        static let maxImageSizeInKB = 2000
    }

    private func submitBug() {
        Task {
            if let imageData = UIImage(named: "testImage")?.compressTo(maxSizeInKB: Constants.maxImageSizeInKB) {
                // it takes array of images as a scalable feature for future usage
                await viewModel.reportBug(description: "we need help", images: [imageData, imageData])
            }
        }
    }

    private func handleSignInButton() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                                              as? UIWindowScene)?.windows.first?.rootViewController
        else {return}
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/spreadsheets"]
        ) { signInResult, error in
            guard let result = signInResult else {
                // Inspect error
                return
            }
            //     TODO:       isSignedIn = true
        }
    }
}

private extension String {
    static let bugDescriptionPlaceholder = "- Bug Description"
}



#Preview {
    ContentView(viewModel: ReportBugViewModel(bugService: GoogleSheetsService(httpClient: URLSessionHTTPClient())))
        .environment(\.isSignedIn, true)
}
