//
//  ScheduleParser.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 1/28/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import Foundation
import Keys


// MARK: Schedule data structures
struct Section: CustomStringConvertible {
    var title: String
    var description: String {
        return title
    }
}

struct Event: CustomDebugStringConvertible {

    // @TODO: Computed property to convert String->Date
    // Note that "day" is 0 for sat, 1 for sun, etc.
    // Note that section is for UI sections.
    var day: Int
    var section: Int
    var time: Date
    var timeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E hh:mm a"
        dateFormatter.timeZone = TimeZone(identifier: "UTC") // Already in ET, dont convert again
        return dateFormatter.string(from: time)
    }
    var title: String
    var location: String
    var description: String
    var uuid: String

    init(day: Int, section: Int, time: Date, title: String, location: String, description: String, uuid: String) {
        self.day         = day
        self.section     = section
        self.time        = time
        self.title       = title
        self.location    = location
        self.description = description
        self.uuid = uuid
    }

    init() {
        self.init(day: 0, section: 0, time: Date(), title: "", location: "", description: "", uuid: "")
    }

    // Using "debugDescription" instead of "description" because of name conflict with my "description" property.
    var debugDescription: String {
        return "\(day), \(section), \(timeString), \(title), \(location), \(self.description), \(self.uuid)"
    }
}

/**
 * SECTION VS. SECTION VS. DAY
 * In the spreadsheet, each day is broken down as a different section.
 * However, in the Table View, each uniquely-timed event is broken down into different sections.
 * This class has the totally-not-confusing responsibility of converting the Spreadsheet "section"
 * to UI's "day", and calculating what UI "section" to use, depending on the event.
 * So, be warned!
 */
class ScheduleParser {

    // Wow! We've already hit one of these.
    // This is used by the UI, so it treats Schedule sections as days, and real sections as sections.
    //
    // Day index starts at -1, because the event is re-created every row iteration.
    // Because the section headers are rows themselves, this accounts for the first section header
    // "eating up" the -1st index.
    static var dayIndex = -1
    static var sectionIndex = 0

    // Last known collection of Events
    static var events = [Event]()

    // To make this a bit nicer for the UI...
    static var sectionCount: Int {
        switch dayIndex {
        case -1: return 0
        default: return sectionIndex
        }
    }

    // MARK: Data structures for parsing

    // Spreadsheet sections
    private enum ScheduleKeyword: String {
        case section = ":section"
        case event = ":item"
    }

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
        let numberValue: Int? // number value is unused but we keep it here for the model
        var description: String {
            return stringValue ?? String(numberValue ?? -1)
        }
    }

    /**
     * Retrieve and parse the events from the spreadsheet.
     * Potential issue: URLSession request thread may not be properly closed due to escaping closure? (Should be fine!)
     */
    static func retrieveEvents(completion: @escaping () -> ()) {

        // Reset our model
        self.events.removeAll()
        self.dayIndex = -1
        self.sectionIndex = 0

        // MARK: HTTP Things
        let sheetsFields = "fields=sheets(data.rowData.values.userEnteredValue)"
        let sheetsKey = BrickHackMobileKeys().googleSheetsAPIKey
        let spreadsheetID = "1eCEF8d4jkSMcY_nZue93roCCdkbyfiBG0G0XZ5KV9xI"
        let sheetsURL = URL(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetID)?\(sheetsFields)&key=\(sheetsKey)")!
        let request = URLRequest(url: sheetsURL)

        // MARK: The Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            guard error == nil else {
                // @TODO: Error handle
                print(error!)
                return
            }

            guard let data = data else {
                // @TODO: Error handle
                print("no data")
                return
            }

            do {
                // Decode JSON
                let welcome = try JSONDecoder().decode(Welcome.self, from: data)

                // Send events to the real parse
                parseEvents(data: welcome)

                // Return
                completion()

            } catch let error {
                // @TODO: Error handle (JSON parse error)
                print("it broke")
                print(error)
            }
        }

        task.resume()

    }

    // MARK: Parsing
    // Postcondition: Events that are not fully defined will be SILENTLY SKIPPED.
    // @FIXME: Add support for empty-description events!!
    // Sets event data as a field
    private static func parseEvents(data: Welcome) {

        // The parse loop
        // @FIXME: Using 3rd sheet as test, convert to 1st for production
        for (rowIndex, rowData) in data.sheets[2].data[0].rowData.enumerated() {

            // See comment below for how this skip variable functions
            var skip = false
            var currentEvent = Event()

            // Use indexing to more accurately determine column purpose
            for columnIndex in 0..<rowData.columns.count {

                // Skip section day header title ("Saturday", "Sunday").
                // "section" 0 is Saturday, 1 is sunday
                // Note that this is NOT the same as Table View sections -- remember, we are only in the model!
                // (and that's how it was named on the spreadsheet)
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
                // @TODO: This switch/struct is overengineered, reduce
                switch ScheduleKeyword(rawValue: cellText) {
                case .section:

                    // Set the section tag on the current event.
                    currentEvent.section = dayIndex
                    dayIndex += 1

                    // Skip the next iteration, which just has the section day title.
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
                    break

                case 1: currentEvent.time = stringToDate(cellText) ?? Date()
                case 2: currentEvent.title = cellText
                case 3: currentEvent.location = cellText
                case 4: currentEvent.description = cellText
                case 5: currentEvent.uuid = cellText

                    // Once we reach the fifth case, we know we're at the end of the data for a cell.
                    // This means that now we can reset the event!
                    self.events.append(currentEvent)
                    currentEvent = Event()

                    // However, we also need to figure out what UI section the data is in.
                    // Assuming events are in cronological order:
                    if let lastEventTime = events.last?.timeString {

                        // If the current and previous event times are not equal,
                        // we need a new UI section to handle the new time.
                        if lastEventTime != currentEvent.timeString {
                            sectionIndex += 1
                        } else {
                            // Otherwise, keep them in the same section.
                        }
                    }
                default: break
                }

            }
        }

    }


    private static func stringToDate(_ text: String) -> Date? {

        // Convert the spreadsheet time into a "blank" Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let convertedTime = dateFormatter.date(from: text)

        guard convertedTime != nil else {
            return nil
        }

        // Build the final date
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(identifier: "America/New_York") // Might not be req'd but works
        dateComponents.year = 2020
        dateComponents.month = 2
        dateComponents.hour = Calendar.current.component(.hour, from: convertedTime!)
        dateComponents.minute = Calendar.current.component(.minute, from: convertedTime!)

        // Construct the proper day
        // 0: sat, 1: sun
        if dayIndex <= 0 {
            dateComponents.day = 8
        } else {
            dateComponents.day = 9
        }

        return Calendar.current.date(from: dateComponents)
    }

    // Helper function for debugging JSON
    private func prettyPrintJSON(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        guard let json2 = json else {
            print("oopsie")
            // @TODO: JSON error
            return
        }

        let jsonData = try? JSONSerialization.data(withJSONObject: json2, options: [.prettyPrinted])

        print(String(data: jsonData!, encoding: .utf8)!)
    }


}
