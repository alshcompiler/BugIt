//
//  BugItApp.swift
//  BugIt
//
//  Created by Mostafa Sultan on 10/08/2024.
//

import SwiftUI
import GoogleSignIn
import netfox

@main
struct BugItApp: App {
    @State private var isLoading = true
    @State private var isSignedIn = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            NFX.sharedInstance().start()
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        isSignedIn = user != nil
                                        isLoading = false
                                }
                            }
                        }
                } else {
                    ContentView(
                        viewModel: ReportBugViewModel(bugService: GoogleSheetsService(httpClient: URLSessionHTTPClient()))
                    )
                    .transition(.opacity)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .environment(\.isSignedIn, isSignedIn)
                }
            }.animation(.easeInOut, value: isLoading)
        }
    }
}
