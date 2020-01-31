//
//  ScheduleTableViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 1/20/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit
import TimelineTableViewCell
import Toaster

class ScheduleTableViewController: UITableViewController {


    // MARK: Ivars
    var scheduleTimer = Timer()

    // Colors for dataset
    // @TODO: Double check w/ design on these colors
    let backColor = UIColor(named: "primaryColor")!
    let frontColor = UIColor(named: "timelineBackColor")!

    // Custom wrapper struct around an Event, to store additional UI parameters. Namely:
    // timelinePoint: whether or not the event has a dot to the left
    // allColor: a defined color for the timeline, for this event
    struct TimelineEvent: CustomStringConvertible {
        var timelinePoint: TimelinePoint?
        var isFavorite: Bool
        var allColor: UIColor
        var event: Event

        init(timelinePoint: TimelinePoint?, isFavorite: Bool, allColor: UIColor, event: Event) {
            self.timelinePoint = timelinePoint
            self.isFavorite = isFavorite
            self.allColor = allColor
            self.event = event
        }

        init(allColor: UIColor, event: Event) {
            self.init(timelinePoint: nil, isFavorite: false, allColor: allColor, event: event)
        }

        init() {
            self.init(timelinePoint: nil, isFavorite: false, allColor: UIColor.clear, event: Event())
        }

        var description: String {
            return "\(event.title)| \(event.description)"
        }
    }
    var timelineEvents = [TimelineEvent]()


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
        scheduleTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refreshTimeline), userInfo: nil, repeats: true)
        scheduleTimer.fire()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Stop timer when view is not visible
        scheduleTimer.invalidate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // This property is stored in the ScheduleParser,
        // as this is pretty much the only time it's needed here.
        print("section count: \(ScheduleParser.sectionCount)")
        return ScheduleParser.sectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of events with a matching section number
        return timelineEvents.filter({ $0.event.section == section }).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

        // Grab from our custom config
        // Description unused for now
//        let (timelinePoint, allColor, title, description, isFavorite, date)

        let currentTimelineEvent = timelineEvents[convertIndex(fromIndexPath: indexPath)]

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

        // Colors, and point
        // If point is nil, stick zero width point there
        cell.backgroundColor = UIColor.clear
        cell.timeline.backColor = currentTimelineEvent.allColor
        cell.timelinePoint = currentTimelineEvent.timelinePoint ??
            TimelinePoint(diameter: 0, color: currentTimelineEvent.allColor, filled: true)
        cell.timeline.frontColor = currentTimelineEvent.allColor

        // If point is filled, set FRONTCOLOR to match rest of list, and show bubble.
        // (point is current bit)
        if (currentTimelineEvent.timelinePoint?.isFilled ?? false) {
            // These colors are a bit counterintuitive but it works ¯\_(ツ)_/¯
            cell.timeline.backColor = frontColor
            // Sets white text no matter what, due to contrastive background of bubble (set later in method)
            cell.titleLabel.textColor = UIColor.white
            cell.bubbleEnabled = true
        } else {
            // Only current item gets button.
            // @TODO: Check with design on this one.
            cell.bubbleEnabled = false
        }

        // Text content
        cell.titleLabel.text = currentTimelineEvent.event.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
//        cell.descriptionLabel.text = dateFormatter.string(from: currentTimelineEvent.event.timeString)
        // @FIXME: Convert string to date and parse here
        cell.descriptionLabel.text = currentTimelineEvent.event.description

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
        favButton.isSelected = currentTimelineEvent.isFavorite

        // Confgure bubble
        cell.bubbleColor = UIColor(named: "primaryColor")!
        cell.bubbleBorderColor = UIColor.clear

        // Disable selection per cell
        cell.selectionStyle = .none

        // Layout adjustment
        // (Accessory adjustment is done in @peterkos/TimelineTableViewCell)
        cell.timeline.leftMargin = 30.0

        return cell
    }


    // Helper function to get a global index for an event from its local table index
    // Section > Row:
    // 0
    //   0
    //   1
    // 1
    //   0     This has global index 2, local index 0.
    private func convertIndex(fromIndexPath indexPath: IndexPath) -> Int {

        var eventSum = 0

        for secIndex in 0..<indexPath.section {
            let eventsInSection = timelineEvents.filter({ $0.event.section == secIndex })
            eventSum += eventsInSection.count
        }

        return eventSum
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

        // Reject if indices are invalid
        guard favButton.section != nil && favButton.row != nil else {
            MessageHandler.showInvalidFavoriteButtonError()
            return
        }

        // Update view
        // (FavoriteButton subclass handles this condition)
        favButton.isSelected = !favButton.isSelected

        // Update model
        // (We handle this condition!)
        let indexPath = IndexPath(row: favButton.row!, section: favButton.section!)
        print("User did something to \(timelineEvents[convertIndex(fromIndexPath: indexPath)].event.title)")

        // @TODO: Handle updating favorite with server
        // @TODO: Handle notifying users on their favorited events
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
        guard let sectionDate = timelineEvents.filter({ $0.event.section == section }).first?.event.timeString else {
            cell.textLabel!.text = "Unknown Time"
            return cell
        }

        // Otherwise set proper date
//        cell.textLabel!.text = dateFormatter.string(from: sectionDate)
        // @FIXME: Proper date parsing
        cell.textLabel!.text = sectionDate


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

    // Set on a Timer to run every so often
    // Updates the timer dispay to highlight the current event.
    // Note: The topmost event is ALWAYS highlighted, even if it has not occured yet.
    // (This is done in the dequeueCell tableview delegtae method)
    @objc func refreshTimeline() {

        // First, get an updated verison of the schedule
        // (Handles UI, threaded)
        updateSchedule()

        // @FIXME: Update to reflect new model
        // Start at -1 as we look at the next index to see if the current is over yet
        /*
        for sectionIndex in -1..<ScheduleParser.sectionCount {

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
         */


        // And of course, reload the table.
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

    // Updates the listing of events from the Google Sheet
    func updateSchedule() {

        DispatchQueue.main.async {
            Toast(text: "Getting the latest schedule...").show()
        }

        // Do it
        ScheduleParser.retrieveEvents {

            // On completion, update our copy of events
            // (Rewrite instead of merge because merge logic is hard)
            self.timelineEvents.removeAll()
            print("Cleared timeline events.")
            for event in ScheduleParser.events {
                // @TODO: Fix color?
                self.timelineEvents.append(TimelineEvent(allColor: self.frontColor, event: event))
            }

            // Finally, update the table now that our model is full
            DispatchQueue.main.async {

                self.tableView.reloadData()

                print("EVENTS AFTER REFRESH: ")
                for event in self.timelineEvents {
                    print(event)
                }

                Toast(text: "Updated the schedule!").show()
            }
        }
    }

}
