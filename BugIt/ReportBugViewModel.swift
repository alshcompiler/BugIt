import Foundation

@MainActor public class ReportBugViewModel: ObservableObject {
    let bugService: BugServices

    init(bugService: BugServices) {
        self.bugService = bugService
    }

    private func handleTodayTab() async throws {
        let response = try await bugService.getSheets()
        let tabID: Int
        if let tab =  response.todayTabID {
            tabID = tab
        } else {
            tabID = try await bugService.createTab(title: .today)
            // adding headers to the newly created sheet
            try await bugService.recordBug(tabName: .today, description: "Bug description", imageURLs: ["screenshot URLs..."])
        }
        var tabs = UserDefaultsShared.sheetTabs
        tabs[.today] = tabID
        UserDefaultsShared.sheetTabs = tabs
    }
    
    func reportBug(description: String) async {
        do {
            // only handle checking existing tab or creating new one if no record of it exists
            if UserDefaultsShared.sheetTabs[.today] == nil {
                try await handleTodayTab()
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
