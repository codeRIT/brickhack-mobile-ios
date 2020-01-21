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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register the nib for TimelineTBVCell
        let nibURL = Bundle(for: TimelineTableViewCell.self).url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(url: nibURL!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")

        // Remove separator lines
        tableView.separatorStyle = .none

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sampleData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sampleData[section]?.count ?? 0
    }

    let sampleData: [Int: [(TimelinePoint, UIColor, String, String)]] = [
        0:[
        (TimelinePoint(), UIColor.black, "12:30", "Description"),
        (TimelinePoint(), UIColor.black, "15:30", "Description."),
        (TimelinePoint(color: UIColor.green, filled: true), UIColor.green, "16:30", "Description."),
        (TimelinePoint(), UIColor.clear, "19:00", "Description.")
        ], 1:[
        (TimelinePoint(), UIColor.lightGray, "08:30", "Description."),
        (TimelinePoint(), UIColor.lightGray, "09:30", "Description."),
        (TimelinePoint(), UIColor.lightGray, "10:00", "Description."),
        (TimelinePoint(), UIColor.lightGray, "11:30", "Description."),
        (TimelinePoint(color: UIColor.red, filled: true), UIColor.red, "12:30", "Description."),
        (TimelinePoint(color: UIColor.red, filled: true), UIColor.red, "13:00", "Description."),
        (TimelinePoint(color: UIColor.red, filled: true), UIColor.lightGray, "15:00", "Description."),
        (TimelinePoint(), UIColor.lightGray, "17:30", "Description."),
        (TimelinePoint(), UIColor.lightGray, "18:30", "Description."),
        (TimelinePoint(), UIColor.lightGray, "19:30", "Description."),
        (TimelinePoint(), backColor: UIColor.clear, "20:00", "Description.")
    ]]


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

        let (timelinePoint, timelineBackColor, title, description) = sampleData[indexPath.section]![indexPath.row]

        cell.timelinePoint = timelinePoint
        cell.timeline.backColor = timelineBackColor
        cell.timeline.frontColor = UIColor.darkGray
        cell.timeline.leftMargin = 30.0
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description

        // Set label color properly depending on dark mode, or no dark mode option
        if #available(iOS 13.0, *) {
            cell.titleLabel.textColor = UIColor.label
        } else {
            cell.titleLabel.textColor = UIColor.black
        }

        // Assign primary accent color as timeline line color (defined in asset catalog)
//        cell.timeline.frontColor = UIColor(named: "primaryColor")!

        // The gray popup square, used to notate the time
//        cell.titleLabel.text = "9:30am"
        cell.bubbleEnabled = false

        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
