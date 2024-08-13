//
//  GoogleSheetsUtil.swift
//  BugIt
//
//  Created by Mostafa Sultan on 11/08/2024.
//

import GoogleSignIn

protocol BugServices {
    func recordBug(description: String) async throws -> Data
}

struct GoogleSheetsService: BugServices {
    let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func recordBug(description: String) async throws -> Data {
        let data = try await httpClient.performRequest(
            method: .get,
            url: "https://sheets.googleapis.com/v4/spreadsheets/" + .spreadSheetID
        )

        return data
    }


    private func createTab() {

    }

    private func chackTaps() {

    }
}

private extension String {
    static let spreadSheetID = "1_OciZkPvDSsU-XQvPdXvnfNHLZ-vGlqK0weukvPDbwg"
}
