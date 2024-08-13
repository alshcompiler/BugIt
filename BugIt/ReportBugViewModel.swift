import Foundation

@MainActor public class ReportBugViewModel: ObservableObject {
    let bugService: BugServices

    init(bugService: BugServices) {
        self.bugService = bugService
    }

    func reportBug(description: String) async {
        do {
            let data = try await bugService.recordBug(description: description)
        } catch {
            print(error.localizedDescription)
        }
    }
}
