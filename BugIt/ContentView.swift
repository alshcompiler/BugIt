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
    var body: some View {
        GoogleSignInButton(action: handleSignInButton)
    }
}

private func handleSignInButton() {
    guard let presentingViewController = (UIApplication.shared.connectedScenes.first
              as? UIWindowScene)?.windows.first?.rootViewController
          else {return}
    GIDSignIn.sharedInstance.signIn(
        withPresenting: presentingViewController
    ) { signInResult, error in
        guard let result = signInResult else {
          // Inspect error
          return
        }
        // If sign in succeeded, display the app's main content View.
      }
  }

#Preview {
    ContentView()
}
