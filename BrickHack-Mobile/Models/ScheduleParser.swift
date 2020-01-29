//
//  ScheduleParser.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 1/28/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import Foundation
import Keys

class ScheduleParser {

    // MARK: Data structures for parsing
    // Used during parsing
    private enum ScheduleKeyword: String {
        case section = ":section"
        case event = ":item"
    }

    private struct Section: CustomStringConvertible {
        var title: String
        var description: String {
            return title
        }
    }

    // MARK: Struct Hell
    // Google loves their indentation, but we ony care about the last two levels or so.
    // All these structs serve to let Swift's JSON deserializer auto-unwarp down to the level we need.
    private struct Welcome: Codable {
        let sheets: [Sheet]
    }

    private struct Sheet: Codable {
        let data: [Datum]
    }

    private struct Datum: Codable {
        let rowData: [RowDatum]
    }

    private struct RowDatum: Codable {
        let columns: [Column]

        // Map the GSheets "values" key into something readable by mere mortals ("columns")
        private enum CodingKeys: String, CodingKey {
            case columns = "values"
        }
    }

    private struct Column: Codable {
        let userEnteredValue: UserEnteredValue?
    }

    private struct UserEnteredValue: Codable, CustomStringConvertible {
        let stringValue: String?
        let numberValue: Int?
        var description: String {
            return stringValue ?? String(numberValue ?? -1)
        }
    }

    // This is our main Event data struct
    struct Event: CustomDebugStringConvertible {

        // @TODO: Computed property to convert String->Date
        var section: Int
        var timeString: String
        var title: String
        var location: String
        var description: String

        init(section: Int, timeString: String, title: String, location: String, description: String) {
            self.section     = section
            self.timeString  = timeString
            self.title       = title
            self.location    = location
            self.description = description
        }

        // Convinence init
        init() {
            self.init(section: 0, timeString: "", title: "", location: "", description: "")
        }

        // Using "debugDescription" instead of "description" because of name conflict with my "description" property.
        var debugDescription: String {
            return "\(section), \(timeString), \(title), \(location), \(self.description)"
        }
    }

    // MARK: Outward-facing data structures
    var events = [Event]()

    func makeRequestAndParse() {

        // MARK: HTTP Things
        let sheetsFields = "fields=sheets(data.rowData.values.userEnteredValue)"
        let sheetsKey = BrickHackMobileKeys().googleSheetsAPIKey
        let spreadsheetID = "1eCEF8d4jkSMcY_nZue93roCCdkbyfiBG0G0XZ5KV9xI"
        let sheetsURL = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetID)?\(sheetsFields)&key=\(sheetsKey)")!
        let request = URLRequest(url: sheetsURL)

        // MARK: The Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }

            guard let data = data else {
                print("no data")
                return
            }

            do {
                let welcome = try JSONDecoder().decode(Welcome.self, from: data)
                self.parse(data: welcome)

            } catch let error {
                // @TODO: Use JSONError from MessageHandler.
                print("it broke")
                print(error)
            }
        }

        task.resume()

    }

    // MARK: Parsing
    // Postcondition: Events that are not fully defined will be SILENTLY SKIPPED.
    // @FIXME: Add support for empty-description events!!
    private func parse(data: Welcome) {

        // Section index starts at -1, because the event is re-created every row iteration.
        // Because the section headers are rows themselves, this accounts for the first seciton header
        // "eating up" the -1st index.
        var sectionIndex = -1

        // The parse loop
        for (rowIndex, rowData) in data.sheets[2].data[0].rowData.enumerated() {

            var skip = false
            var currentEvent = Event()

            // Use indexing to more accurately determine column purpose
            for columnIndex in 0..<rowData.columns.count {

                // Skip section day header title ("Saturday", "Sunday")
                // @TODO: Might just leave hardcoded in the spreadsheet.
                if skip {
                    skip = false
                    continue
                }

                // Check for valid text
                // (And convinence so we don't have to read this mess of an index)
                // Note: error message is printed in SHEETS index (1-based) for easier debugging there.
                guard let cellText = rowData.columns[columnIndex].userEnteredValue?.stringValue else {
                    print("Unable to parse cell value \(rowData.columns[columnIndex]) at row \(rowIndex + 1), column \(columnIndex + 1)")
                    continue
                }

                // Now, onto the core parsing.

                // First, parse the schedule
                // (if default case, it is hopefully event data)
                switch ScheduleKeyword(rawValue: cellText) {
                case .section:

                    // Set the section tag on the current event.
                    currentEvent.section = sectionIndex
                    print("Added, incrementing section \(sectionIndex) on event \(currentEvent)")
                    sectionIndex += 1

                    // Skip the next iteration, whic just has the section day title.
                    skip = true
                    continue

                case .event: break
                case .none: break
                }

                // Now, figure out what part of the Event struct we're filling.
                switch columnIndex {
                case 0:
                    // This is the ScheduleKeyword, handled in the above switch statement
                    // However we use this opportunity to set the schedule index tag from the previous row.
                    currentEvent.section = sectionIndex
                    print("\(currentEvent), for section index \(sectionIndex)")
                    break

                case 1: currentEvent.timeString = cellText // @TODO: Parse this here
                case 2: currentEvent.title = cellText
                case 3: currentEvent.location = cellText
                case 4:
                    currentEvent.description = cellText

                    // Once we reach the fourth case, we know we're at the end of the data for a cell.
                    // This means that now we can reset the event!
                    self.events.append(currentEvent)
                    currentEvent = Event()

                default: break
                }

            }
        }

        // Print stuff out
        print("-----------")
        print("Events:")
        for event in self.events {
            print(event)
        }
    }

    // Helper function for debugging JSON
    private func prettyPrintJSON(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let json2 = json else {
            print("oopsie")
            return
        }

        let jsonData = try? JSONSerialization.data(withJSONObject: json2, options: [.prettyPrinted])

        print(String(data: jsonData!, encoding: .utf8)!)
    }


}
