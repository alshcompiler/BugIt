import Foundation


public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
}

public protocol HTTPClient {
    func performRequest(method: HTTPMethod,
                        url: String,
                        parameters: [String: Any],
                        encoding: ParameterEncoding,
                        isAuthorized: Bool) async throws -> Data
    func upload(url: String, fileData: Data, parameters: [String: String]) async throws
}

public enum NetworkError: LocalizedError {
    case connectivity
    case invalidData
    case unAuthorized
    case notValidURL
    case unDefined

    public var errorDescription: String? {
        switch self {
        case .connectivity:
            return "Please check your internet connection"
        case .unAuthorized:
            return "You have been logged out, please try to login again"
        default:
            return "Something went wrong, please try again later"
        }
    }

}

public extension HTTPClient {
    func performRequest(method: HTTPMethod, url: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .urlEncoding, isAuthorized: Bool = true) async throws -> Data {
        try await performRequest(method: method, url: url, parameters: parameters, encoding: encoding, isAuthorized: isAuthorized)
    }
}
