import Foundation
import GoogleSignIn
import BugItNetwork

protocol BugServices {
    func getSheets() async throws -> GoogleSheetsModel
    func createTab(title: String) async throws -> Int
    func uploadScreenshot(imagesData: [Data]) async throws -> [String]
    func recordBug(tabName: String, description: String, imageURLs: [String]) async throws
}

struct GoogleSheetsService: BugServices {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
    }

    func createTab(title: String) async  throws -> Int {
        let parameters = [
            "requests": [
                [
                    "addSheet": [
                        "properties": [
                            "title": title
                        ]
                    ]
                ]
            ]
        ]
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString else {
            assertionFailure("access token can not be nil")
            throw NetworkError.unAuthorized
        }

        let httpHeader: [String: String] = ["Authorization" : "Bearer \(accessToken)"]
        let response = try await httpClient.performRequest(
            method: .post,
            url: .baseURL + .spreadSheetID + ":batchUpdate",
            parameters: parameters,
            encoding: .jsonEncoding,
            headers: httpHeader,
            responseType: CreatedSheetModel.self
        )
        guard let createdSheetID = response.replies.first?.addSheet.properties.sheetID else {
            throw NetworkError.invalidData
        }
        return createdSheetID
    }

    func getSheets() async throws -> GoogleSheetsModel {
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString else {
            assertionFailure("access token can not be nil")
            throw NetworkError.unAuthorized
        }

        let httpHeader: [String: String] = ["Authorization" : "Bearer \(accessToken)"]
        let response = try await httpClient.performRequest(
            method: .get,
            url: .baseURL + .spreadSheetID,
            headers: httpHeader,
            responseType: GoogleSheetsModel.self
        )

        return response
    }

    func uploadScreenshot(imagesData: [Data]) async throws -> [String] {
        var imageUrls: [String] = []
        let httpHeader: [String: String] = ["Authorization" : .imagurCLientID]
        try await withThrowingTaskGroup(of: String.self) { group in
            for imageData in imagesData {
                group.addTask {
                    try await httpClient.uploadMultipart(
                        url: "https://api.imgur.com/3/image",
                        fileData: imageData,
                        headers: httpHeader,
                        responseType: ImageResponseModel.self).data.link
                }
            }

            for try await imageURL in group {
                imageUrls.append(imageURL)
            }
        }
        return imageUrls
    }

    func recordBug(tabName: String, description: String, imageURLs: [String]) async throws {

        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString else {
            assertionFailure("access token can not be nil")
            throw NetworkError.unAuthorized
        }

        let httpHeader: [String: String] = ["Authorization" : "Bearer \(accessToken)"]

        let parameters = ["values" : [[description] + imageURLs]]
        let url =  .baseURL + .spreadSheetID + "/values/\(tabName):append?valueInputOption=RAW"
        _ = try await httpClient.performRequest(
            method: .post,
            url: url,
            parameters: parameters,
            encoding: .jsonEncoding,
            headers: httpHeader,
            responseType: Data.self
        )
    }
}

private extension String {
    static let spreadSheetID = "1_OciZkPvDSsU-XQvPdXvnfNHLZ-vGlqK0weukvPDbwg"
    static let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/"
    static let imagurCLientID = "Client-ID e74e94ffb32528f"
}
