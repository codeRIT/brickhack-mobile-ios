//
//  ProfileTableViewController.swift
//  
//
//  Created by Peter Kos on 1/20/20.
//

import UIKit


/*
 * Just a static TableView to hold the user's
 */
class ProfileTableViewController: UITableViewController {

    // MARK: IBOutlets
    // These are set in the prepareForSegue in ResourcesViewController
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    // MARK: Properties
    var nameText: String?
    var infoText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fill properites
        self.nameLabel.text = nameText ?? "Unknown Name"
        self.infoLabel.text = infoText ?? "Unknown Major"

        // Fix header issue
        let view = UIView()
        view.frame.size.height = .leastNormalMagnitude
        self.tableView.tableHeaderView = view

        self.tableView.separatorStyle = .singleLine
    }

    // This doesn't work!
    // When a header is not defined, iOS creates a default one with a default height.
    // See the viewForHeaderInSection method for the real fix.
    // src: https://stackoverflow.com/a/22185534/1431900
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

}
