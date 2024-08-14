//
//  GoogleSheetsUtil.swift
//  BugIt
//
//  Created by Mostafa Sultan on 11/08/2024.
//

import GoogleSignIn

protocol BugServices {
    func getSheets() async throws -> GoogleSheetsModel
    func createTab(title: String) async  throws -> Int
    func recordBug(tabName: String, description: String, imageURLs: [String]) async throws -> Data
}

struct GoogleSheetsService: BugServices {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func recordBug(tabName: String, description: String, imageURLs: [String]) async throws -> Data {

        let parameters = ["values" : [[description] + imageURLs]]
        let url =  .baseURL + .spreadSheetID + "/values/\(tabName):append?valueInputOption=RAW"
        let response = try await httpClient.performRequest(
            method: .post,
            url: url,
            parameters: parameters,
            encoding: .jsonEncoding,
            responseType: Data.self
        )

        return response
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
        let response = try await httpClient.performRequest(
            method: .post,
            url: .baseURL + .spreadSheetID + ":batchUpdate",
            parameters: parameters,
            encoding: .jsonEncoding,
            responseType: CreatedSheetModel.self
        )
        guard let createdSheetID = response.replies.first?.addSheet.properties.sheetID else {
            throw NetworkError.invalidData
        }
        return createdSheetID
    }

    func getSheets() async throws -> GoogleSheetsModel {
        let response = try await httpClient.performRequest(
            method: .get,
            url: .baseURL + .spreadSheetID,
            responseType: GoogleSheetsModel.self
        )

        return response
    }
}

private extension String {
    static let spreadSheetID = "1_OciZkPvDSsU-XQvPdXvnfNHLZ-vGlqK0weukvPDbwg"
    static let baseURL = "https://sheets.googleapis.com/v4/spreadsheets/"
}
