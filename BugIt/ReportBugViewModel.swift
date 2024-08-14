import Foundation

@MainActor public class ReportBugViewModel: ObservableObject {
    let bugService: BugServices

    init(bugService: BugServices) {
        self.bugService = bugService
    }

    func reportBug(description: String) async {
        do {
            let response = try await bugService.getSheets()
            let tab: Int
            if let tabID =  response.todayTabID {
                tab = tabID
            } else {
                tab = try await bugService.createTab(title: .today)
            }

            try await bugService.recordBug(tabName: .today, description: "description", imageURLs: ["https://images.app.goo.gl/Y5Z7frTDHmaEe9Nf8", "https://images.app.goo.gl/Vwj3RcewGNNSDWtm8"])
        } catch {
            print(error.localizedDescription)
        }
    }
}

private extension GoogleSheetsModel {
    var todayTabID: Int? {
        sheets.first { $0.properties.title == .today }?.properties.sheetID
    }
}

private extension String {
    static var today: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: Date())
    }
}
