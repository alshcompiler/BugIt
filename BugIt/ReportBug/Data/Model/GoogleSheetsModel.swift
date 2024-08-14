import Foundation

// MARK: - GoogleSheetsModel

struct GoogleSheetsModel: Codable {
    let spreadsheetID: String
    let sheets: [Sheet]

    enum CodingKeys: String, CodingKey {
        case spreadsheetID = "spreadsheetId"
        case sheets
    }
}

// MARK: - Sheet

struct Sheet: Codable {
    let properties: SheetProperties
}

// MARK: - SheetProperties
struct SheetProperties: Codable {
    let title: String
    let sheetID: Int
    let index: Int

    enum CodingKeys: String, CodingKey {
        case title
        case sheetID = "sheetId"
        case index
    }
}

// MARK: - Welcome
struct CreatedSheetModel: Codable {
    let replies: [Reply]
}

// MARK: - Reply
struct Reply: Codable {
    let addSheet: Sheet
}
