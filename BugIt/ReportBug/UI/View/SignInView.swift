import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    let handleSignInButton: () -> Void

    var body: some View {
        VStack {
            Text("Sign in")
                .font(.title)
                .bold()
                .padding(.top, 20)

            Spacer()
                .frame(height: 100)

            GoogleSignInButton(action: handleSignInButton)
        }
    }
}
