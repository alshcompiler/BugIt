import Foundation

struct ImageResponseModel: Codable {
    let data: ImageLink
}

// MARK: - DataClass
struct ImageLink: Codable {
    let link: String
}
