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
    var sampleData: [Int: [(TimelinePoint?, UIColor, String, String, Bool)]] = [:]

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
        scheduleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in

            print("--------------")
            print("OLD DATA FOR SECTION 0")
            print(self.sampleData[0]?.last as Any)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"

            // Don't attempt to convert until data exists
            guard self.sampleData[1]?.first?.2 != nil else {
                return
            }

            // Convert our date string into a date object
            let dateString = dateFormatter.date(from: self.sampleData[1]!.first!.2)

            guard dateString != nil else {
                return
            }

            // Do the comparison
            if (Date.init(timeIntervalSinceNow: 0) >= dateString!) {

                // Goal: If we have passed the current date, move the first item in section 1 to section 0.

                // Move first element of section 1 to end of section 0,
                // and update color to show "completed"
                var newCurrent = self.sampleData[1]!.first!
                newCurrent.1 = self.backColor

                // Only "fill" timeline point if it's defined for that cell
                if (newCurrent.0 != nil) {
                    newCurrent.0 = TimelinePoint(color: self.backColor, filled: true)
                }

                // Reassign to first section
                // @TODO: Why??
                self.sampleData[1]!.removeFirst()
                self.sampleData[0]!.append(newCurrent)
            }

            // And of course, reload the table.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            print("\nNEW DATA FOR SECTION 0")
            print(self.sampleData[0]!.last!)
        })

        scheduleTimer.fire()

        /*
         * Static sample data to use.
         * Some notes:
         *      a) Set nil point to have smooth, continuous line past that event
         *      b) Section 0 (up to last event, which is current item) will be HIGHLIGHTED in primary color.
         *
         * @TODO: Implement with pulled & parsed data from GSheets
         */
        self.sampleData = [
            0:[
            (TimelinePoint(color: backColor, filled: true),  backColor, "12:30", "Description.", true),
            (nil,                                            backColor, "15:30", "Description.", false),
            (TimelinePoint(color: backColor, filled: true),  backColor, "16:30", "Description.", false), // Current item
            ], 1:[
            (TimelinePoint(),                                frontColor, "19:00", "Description.", false),
            (nil,                                            frontColor, "08:30", "Description.", false),
            (nil,                                            frontColor, "09:30", "Description.", false),
            (nil,                                            frontColor, "10:00", "Description.", true),
            (TimelinePoint(),                                frontColor, "11:30", "Description.", false),
            (TimelinePoint(),                                frontColor, "12:30", "Description.", false),
            (TimelinePoint(),                                frontColor, "13:00", "Description.", false),
            (TimelinePoint(),                                frontColor, "15:00", "Description.", false),
            (TimelinePoint(),                                frontColor, "17:30", "Description.", false),
            (TimelinePoint(),                                frontColor, "18:30", "Description.", false),
            (TimelinePoint(),                                frontColor, "19:30", "Description.", false),
            (TimelinePoint(),                                frontColor, "20:00", "Description.", false) ]]

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
        let (timelinePoint, allColor, title, description, favorite) = sampleData[indexPath.section]![indexPath.row]


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
            print("Current element: \(title)")
        } else {

            // Only current item gets button.
            // @TODO: Check with design on this one.
            cell.bubbleEnabled = false
        }

        // Text content
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description

        // Set label color properly depending on dark mode, or no dark mode option.
        // Only change if bubble is not enableld to preserve contrast. Might need tweaking.
        if #available(iOS 13.0, *), !cell.bubbleEnabled {
            cell.titleLabel.textColor = UIColor.label
        } else {
            cell.titleLabel.textColor = UIColor.black
        }

        // Configure favorite accessory
        if favorite {
            cell.accessoryView = UIImageView(image: UIImage(named: "filledStar"))
        } else {
            cell.accessoryView = UIImageView(image: UIImage(named: "emptyStar"))
        }

        // Disable selection per cell
        cell.selectionStyle = .none

        // Layout adjustment
        cell.timeline.leftMargin = 30.0

        return cell
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // @TODO: Obvs read/write to/from server, but also:
        // @TODO: Change local data model, look for a table view delegate
        // @TODO: Check if margin updates when using forked TimelineTableViewCell eventually
    }

}
