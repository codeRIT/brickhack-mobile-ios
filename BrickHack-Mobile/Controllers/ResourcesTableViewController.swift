//
//  ResourcesTableViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 2/4/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit

class ResourcesTableViewController: UITableViewController {

    // MARK: IBOutlets

    // These are set in the prepareForSegue in ResourcesViewController
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!


    // MARK: IBActions

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

    @IBAction func viewPrivacy(_ sender: Any) {
        openURL(url: URL(string: privacyPolicy)!)
    }

    @IBAction func supportSite(_ sender: Any) {
        openURL(url: URL(string: supportURL)!)
    }


    // MARK: Properties

    // Xcode complains when this is implicitly unwrapped, so we are here.
    // Will be instantiated in preivous class using prepareForSegue(:)
    var currentUser: User  = User()
    var nameText: String?  = nil
    var infoText: String?  = nil
    let emergencyNumber    = "585_475_3333"
    let nonEmergencyNumber = "585_475_2853"
    let devpostURL         = "https://brickhack6.devpost.com"
    let slackURL           = "https://brickhack6.slack.com"
    let privacyPolicy      = ""
    let supportURL         = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fix header issue
        let view = UIView()
        view.frame.size.height = .leastNormalMagnitude
        self.tableView.tableHeaderView = view

        // Fill properites
        self.nameLabel.text = nameText ?? "Unknown Name"
        self.infoLabel.text = infoText ?? "Unknown Major"

    }


    // MARK: prepareForSegue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Logout segue -- logout user before loading login view
        if let loginVC = segue.destination as? LoginViewController {
            print("\n\nLOGGED OUT\n\n")
            loginVC.logout()
        }
    }

    // MARK: Helper Functions

    private func openURL(url: URL) {

        guard UIApplication.shared.canOpenURL(url) else {
            MessageHandler.showUnableToOpenURLError(url: url)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }


    // MARK: TableView stuff
    
    // This doesn't work!
    // When a header is not defined, iOS creates a default one with a default height.
    // See the viewForHeaderInSection method for the real fix.
    // src: https://stackoverflow.com/a/22185534/1431900
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }


}
