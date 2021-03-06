//
//  ResourcesViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit

/**
 Acts as a dummy intermediate to pass properties HERE instead of in whatever class attempts to instantiate it.
 Yay for last minute decisions.
 */
class ResourcesViewController: UIViewController {

    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Embedded TableViewController segue
        // This is the main way to reference the ResourcesTableViewCotroller
        // that is contained within this view via an Embed segue.
        if let tableVC = segue.destination as? ResourcesTableViewController {

            // @TODO: Impement thanks
            tableVC.nameText = currentUser.firstName + " " + currentUser.lastName
            tableVC.infoText = "Majoring in " + currentUser.major

        }

    }

}
