import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Text("Loading...")
            Image("mobily", bundle: nil)
            ProgressView()
        }
    }
}
