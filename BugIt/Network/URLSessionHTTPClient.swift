import Foundation

import Alamofire
import Combine
import GoogleSignIn

public class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

        public init(session: URLSession = .shared) {
            self.session = session
        }


    public func performRequest<T: Decodable>(method: HTTPMethod,
                                             url: String,
                                             parameters: [String: Any] = [:],
                                             encoding: ParameterEncoding = .urlEncoding,
                                             isAuthorized: Bool = true,
                                             responseType: T.Type) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers for authorization if needed
        if isAuthorized {
            guard let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString else {
                assertionFailure("access token can not be nil")
                throw NetworkError.unAuthorized
            }
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode parameters
        switch encoding {
        case .urlEncoding:
            if method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                if let urlWithParams = components?.url {
                    request.url = urlWithParams
                }
            } else {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        case .jsonEncoding:
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Perform request and return data
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            // Handle any decoding errors
            throw NetworkError.invalidData
        }
    }

    public func upload(url: String, fileData: Data, parameters: [String: String]) async throws {
//    TODO: handle if needed
//        try await withUnsafeThrowingContinuation { continuation in
//            AF.upload(multipartFormData: { multipartFormData in
//                for (key, value) in parameters {
//                    if let data = value.data(using: .utf8) {
//                        multipartFormData.append(data, withName: key)
//                    }
//                }
//                multipartFormData.append(fileData, withName: "file")
//            }, to: url)
//            .validate()
//            .responseData(completionHandler: { response in
//                switch response.result {
//                case .success:
//                    continuation.resume()
//                case .failure(_):
//                    continuation.resume(throwing: NetworkError.connectivity)
//                }
//            })
//        }
    }
}
