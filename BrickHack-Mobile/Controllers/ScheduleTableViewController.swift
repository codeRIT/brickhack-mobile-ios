//
//  ScheduleTableViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 1/20/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit
import TimelineTableViewCell

class ScheduleTableViewController: UITableViewController {


    // MARK: Ivars
    var scheduleTimer = Timer()

    // Colors for dataset
    // @TODO: Double check w/ design on these colors
    let backColor = UIColor(named: "primaryColor")!
    let frontColor = UIColor(named: "timelineBackColor")!

    // Section 0 represents the previous and current events, colored backColor (except current)
    // Section 1 represents future events, colored frontColor.
    // timelinePoint, allColor, title, description, favorite
    var sampleData: [Int: [(timelinePoint: TimelinePoint?,
        allColor: UIColor, title: String, description: String, isFavorite: Bool, date: Date)]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the nib for TimelineTBVCell
        let nibURL = Bundle(for: TimelineTableViewCell.self).url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(url: nibURL!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")

        // Remove separator lines
        tableView.separatorStyle = .none

        // Set timer for timeline refresh function,
        // which runs each minute (while the screen is visible) and updates the timeline view if necessary.
        // @TODO: Change from 60s to change on every hour, effectively caching the result
        // (or maybe don't bother with cache and do it every time the view is loaded / minimal persistance)
        scheduleTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { timer in

            // Determine which section is currently active
            // (by default, 0)

            guard (!self.sampleData.isEmpty) else {
                return
            }

            for sectionIndex in -1..<self.sampleData.count {

                // Grab the next section's date
                let sectionDate = self.sampleData[sectionIndex + 1]!.first!.date

                // If greater, STOP. We are at the current section.
                if (sectionDate > Date(timeIntervalSinceNow: 0)) {
                    break
                }

                // Otherwise, go on to configure this current section as "passed"
                var currentSection = self.sampleData[sectionIndex]!
                for eventIndex in 0..<currentSection.count {

                    currentSection[eventIndex].allColor = self.backColor

                    // Only "fill" timeline point if it's defined for that cell
                    if (currentSection[eventIndex].timelinePoint != nil) {
                        currentSection[eventIndex].timelinePoint = TimelinePoint(color: self.backColor, filled: true)
                    }
                }
            }

            // And of course, reload the table.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        })

        scheduleTimer.fire()

        /*
         * Static sample data to use.
         * Some notes:
         *      Each section corresponds to a time block. The header of each section will dictate the time.
         *      An event is set to be the current event on a section-by-section basis in viewDidLoad
         *      First point is ALWAYS filled. Rest is set in the timer closure on viewDidLoad.
         *
         * @TODO: Implement with pulled & parsed data from GSheets
         *
         * From Figma: (sample date 2/8/2020)
         * Sat, 9pm (2 things but only one stored),
         * Sun, 12am, 7am, 8am
         */
        self.sampleData = [
            // 9am sat
            0:[
                (TimelinePoint(color: backColor, filled: true),  backColor, "9am 1", "Description.", true, Date(timeIntervalSince1970: 1581170400)),
                (nil,                                            backColor, "9am 2", "Description.", false, Date(timeIntervalSince1970: 1581170400))],
            // 12am sun
            1:[
                (TimelinePoint(),                                frontColor, "12am", "Description.", false, Date(timeIntervalSince1970: 1581224400))],
            // 7am sun
            2:[
                (TimelinePoint(),                                frontColor, "7am", "Description.", false, Date(timeIntervalSince1970: 1581249600))],
            // 8am sun
            3:[
                (TimelinePoint(),                                frontColor, "8am", "Description.", false, Date(timeIntervalSince1970: 1581253200))]]
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Stop timer when view is not visible
        scheduleTimer.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sampleData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sampleData[section]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

        // Grab from our custom config
        // Description unused for now
        let (timelinePoint, allColor, title, description, isFavorite, date) = sampleData[indexPath.section]![indexPath.row]


        /*
        Overview of how cells are drawn

                       ----------------
         backColor     |
         tPoint.color  o 12:30 (bold)
                       |
         frontColor    | Description
                       |
                       ----------------
         */

        // Colors, and point (if not nil)
        cell.timeline.backColor = allColor
        cell.timelinePoint = timelinePoint ?? TimelinePoint(diameter: 0, color: allColor, filled: true)
        cell.timeline.frontColor = allColor

        // If point is filled, set FRONTCOLOR to match rest of list, and show bubble.
        // (point is current bit)
        if (indexPath.section == 0 && indexPath.row == sampleData[0]!.count - 1) {

            // This is a bit counterintuitive but it works ¯\_(ツ)_/¯
            cell.timeline.backColor = frontColor
            cell.bubbleEnabled = true
        } else {

            // Only current item gets button.
            // @TODO: Check with design on this one.
            cell.bubbleEnabled = false
        }

        // Text content
        cell.titleLabel.text = title

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        cell.descriptionLabel.text = dateFormatter.string(from: date)


        // Set label color properly depending on dark mode, or no dark mode option.
        // Only change if bubble is not enableld to preserve contrast. Might need tweaking.
        if #available(iOS 13.0, *), !cell.bubbleEnabled {
            cell.titleLabel.textColor = UIColor.label
        } else {
            cell.titleLabel.textColor = UIColor.black
        }

        // Configure favorite accessory
        let favButton = FavoriteButton(type: .custom)
        // Set images
        favButton.addTarget(self, action: #selector(favoriteTapped(sender:)), for: .touchUpInside)
        cell.accessoryView = favButton
        // Set custom properties
        favButton.section = indexPath.section
        favButton.row = indexPath.row
        favButton.sizeToFit()

        // Now, toggle the stars that are favorited
        favButton.isSelected = isFavorite

        // Confgure bubble
        cell.bubbleColor = UIColor.clear
        cell.bubbleWidth = 20.0
        cell.bubbleBorderColor = UIColor(named: "primaryColor")!

        // Disable selection per cell
        cell.selectionStyle = .none

        // Layout adjustment
        // (Accessory adjustment is done in @peterkos/TimelineTableViewCell)
        cell.timeline.leftMargin = 30.0

        return cell
    }


    // Because of the Wonderful Way UIKit works (https://stackoverflow.com/a/12810613/1431900),
    // we have to define our own UIButton + handler for this accessoryView.
    // To get two points of data (section + row) instead of just one `tag`,
    // we use a subclassed UIButton, FavoriteButton, so we know what exact
    // event was pressed. (row is section-dependent)
    @objc func favoriteTapped(sender: UIButton) {

        // Reject if improper call
        guard let favButton = sender as? FavoriteButton else {
            MessageHandler.showInvalidFavoriteButtonError()
            return
        }

        // Update view
        // (FavoriteButton subclass handles this condition)
        favButton.isSelected = !favButton.isSelected

        // Update model
        // (We handle this condition!)
        sampleData[favButton.section!]![favButton.row!].isFavorite = favButton.isSelected

        // @TODO: Handle updating favorite with server
        // @TODO: Handle notifying users on their favorited events

        print("User did something to \(sampleData[favButton.section!]![favButton.row!].title)")
    }



    // MARK: Section headers and view configuration

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        // Get our dummy cell from IB
        let cell = tableView.dequeueReusableCell(withIdentifier: "header")!

        // Make date formatter for just time
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none

        // Return cell as-is if invlaid data
        guard let sectionDate = sampleData[section]?.first?.date else {
            cell.textLabel!.text = "Unknown Time"
            return cell
        }

        // Otherwise set proper date
        cell.textLabel!.text = dateFormatter.string(from: sectionDate)

        return cell

    }

    // Defined height for the time header slot (e.g., "9am")
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

    // Remove margin between sections
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

}
