//
//  ResourcesTableViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 2/4/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit

class ResourcesTableViewController: UITableViewController {

    // MARK: IBStuff

    @IBAction func callEmergency(_ sender: Any) {

        let emergencyURL = URL(string: "tel://\(emergencyNumber)")!
        openURL(url: emergencyURL)
    }

    @IBAction func callNonEmergency(_ sender: Any) {

        let nonEmergencyURL = URL(string: "tel://\(emergencyNumber)")!
        openURL(url: nonEmergencyURL)
    }

    @IBAction func openDevpost(_ sender: Any) {
        openURL(url: URL(string: devpostURL)!)
    }

    @IBAction func openSlack(_ sender: Any) {
        openURL(url: URL(string: slackURL)!)
    }


    // MARK: Properties

    let emergencyNumber    = "585_475_3333"
    let nonEmergencyNumber = "585_475_2853"
    let devpostURL         = "https://brickhack6.devpost.com"
    let slackURL           = "https://brickhack6.slack.com"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fix header issue
        let view = UIView()
        view.frame.size.height = .leastNormalMagnitude
        self.tableView.tableHeaderView = view
    }

    private func openURL(url: URL) {

        guard UIApplication.shared.canOpenURL(url) else {
            MessageHandler.showUnableToOpenURLError(url: url)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // This doesn't work!
    // When a header is not defined, iOS creates a default one with a default height.
    // See the viewForHeaderInSection method for the real fix.
    // src: https://stackoverflow.com/a/22185534/1431900
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

}
