//
//  ResourcesViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit

class ResourcesViewController: UIViewController {

    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Embedded TableViewController segue
        // This is the main way to reference the ProfileTableViewCotroller
        // that is contained within this view via an Embed segue.
        if let tableVC = segue.destination as? ProfileTableViewController {

            // May just set properties as Strings;
            // this approach calls viewDidLoad() before this data is set,
            // which may lead to odd behavior down the road.
            tableVC.loadViewIfNeeded()

            tableVC.nameLabel.text = currentUser.firstName + " " + currentUser.lastName
            tableVC.schoolLabel.text = "Unknown School"

        }
    }
}
