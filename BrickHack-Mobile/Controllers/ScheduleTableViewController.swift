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

    // Colors for dataset
    // @TODO: Double check w/ design on these colors
    let backColor = UIColor(named: "timelineBackColor")!
    let frontColor = UIColor(named: "primaryColor")!

    // Section 0 represents the previous and current events, colored backColor (except current)
    // Section 1 represents future events, colored frontColor.
    var sampleData: [Int: [(TimelinePoint, UIColor, String, String)]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the nib for TimelineTBVCell
        let nibURL = Bundle(for: TimelineTableViewCell.self).url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(url: nibURL!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")

        // Remove separator lines
        tableView.separatorStyle = .none

        // Instantiate sample data set
        // @TODO: Finish
        self.sampleData = [
            0:[
            (TimelinePoint(),                                backColor, "12:30", "Description"),
            (TimelinePoint(),                                backColor, "15:30", "Description."),
            (TimelinePoint(color: frontColor, filled: true), frontColor, "16:30", "Description."),
            ], 1:[
            (TimelinePoint(),                                frontColor, "19:00", "Description."),
            (TimelinePoint(),                                frontColor, "08:30", "Description."),
            (TimelinePoint(),                                frontColor, "09:30", "Description."),
            (TimelinePoint(),                                frontColor, "10:00", "Description."),
            (TimelinePoint(),                                frontColor, "11:30", "Description."),
            (TimelinePoint(),                                frontColor, "12:30", "Description."),
            (TimelinePoint(),                                frontColor, "13:00", "Description."),
            (TimelinePoint(),                                frontColor, "15:00", "Description."),
            (TimelinePoint(),                                frontColor, "17:30", "Description."),
            (TimelinePoint(),                                frontColor, "18:30", "Description."),
            (TimelinePoint(),                                frontColor, "19:30", "Description."),
            (TimelinePoint(),                                frontColor, "20:00", "Description.")
            ]]

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
        let (timelinePoint, allColor, title, description) = sampleData[indexPath.section]![indexPath.row]


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

        // Colors
        cell.timeline.backColor = allColor
        cell.timelinePoint = timelinePoint
        cell.timeline.frontColor = allColor

        // If point is filled, set backcolor to be the old back color
        if (timelinePoint.isFilled) {
            cell.timeline.backColor = self.backColor
        }

        // Text content
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description

        // Set label color properly depending on dark mode, or no dark mode option
        if #available(iOS 13.0, *) {
            cell.titleLabel.textColor = UIColor.label
        } else {
            cell.titleLabel.textColor = UIColor.black
        }

        // Layout
        cell.timeline.leftMargin = 30.0
        cell.bubbleEnabled = false

        return cell
    }

}
