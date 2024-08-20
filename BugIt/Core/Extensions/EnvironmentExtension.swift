import SwiftUI

private struct IsSignedInKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isSignedIn: Bool {
        get { self[IsSignedInKey.self] }
        set { self[IsSignedInKey.self] = newValue }
    }
}
