import Foundation

import Alamofire
import Combine
import GoogleSignIn

public class AlamofireHTTPClient: HTTPClient {

    public init() {

    }


    public func performRequest(method: HTTPMethod,
                               url: String,
                               parameters: [String: Any] = [:],
                               encoding: ParameterEncoding = .urlEncoding,
                               isAuthorized: Bool = true) async throws -> Data {
        try await withUnsafeThrowingContinuation { continuation in
            do {
                let request = try createRequest(url: url, method: method, parameters: parameters, isAuthorized: isAuthorized, encoding: encoding)
                request.validate().responseData(completionHandler: { response in
                        if let data = response.data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(throwing: NetworkError.connectivity)
                        }
                    })
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    public func upload(url: String, fileData: Data, parameters: [String: String]) async throws {
        try await withUnsafeThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                for (key, value) in parameters {
                    if let data = value.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
                multipartFormData.append(fileData, withName: "file")
            }, to: url)
            .validate()
            .responseData(completionHandler: { response in
                switch response.result {
                case .success:
                    continuation.resume()
                case .failure(_):
                    continuation.resume(throwing: NetworkError.connectivity)
                }
            })
        }
    }

    private func createRequest(url: String, method: HTTPMethod, parameters: [String: Any], isAuthorized: Bool, encoding: ParameterEncoding) throws -> DataRequest {
        let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString
        var headers: HTTPHeaders = []
        if isAuthorized {
            if let accessToken, !accessToken.isEmpty {
                headers = [HTTPHeader.authorization(bearerToken: accessToken)]
            } else {
                throw NetworkError.unAuthorized
            }

        }

        let httpMethod = method.toAlamofireHttpMethod
        return AF.request(url, method: httpMethod, parameters: parameters, encoding: encoding.toAlamofireEncoding, headers: headers)
    }
}

private extension HTTPMethod {
    var toAlamofireHttpMethod: Alamofire.HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}

private extension ParameterEncoding {
    var toAlamofireEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .urlEncoding:
            return URLEncoding.default
        case .jsonEncoding:
            return JSONEncoding.default

        }
    }
}
