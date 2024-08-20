import Foundation

extension String {
    static func generateRandomString(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).compactMap { _ in characters.randomElement() })
        }
}
