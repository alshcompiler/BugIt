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
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ReportBugViewModel(bugService: GoogleSheetsService(httpClient: URLSessionHTTPClient())))
                .onAppear {
                    NFX.sharedInstance().start()
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                        if user == nil {

                        }
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
