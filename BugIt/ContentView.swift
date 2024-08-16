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
    var body: some View {
        GoogleSignInButton(action: handleSignInButton)
    }

    private enum Constants {
        static let maxImageSizeInKB = 2000
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
            Task {
                if let imageData = UIImage(named: "testImage")?.compressTo(maxSizeInKB: Constants.maxImageSizeInKB) {
                    // it takes array of images as a scalable feature for future usage
                    await viewModel.reportBug(description: "we need help", images: [imageData, imageData])
                }
            }
            // If sign in succeeded, display the app's main content View.
          }
      }
}



#Preview {
    ContentView(viewModel: ReportBugViewModel(bugService: GoogleSheetsService(httpClient: URLSessionHTTPClient())))
}
