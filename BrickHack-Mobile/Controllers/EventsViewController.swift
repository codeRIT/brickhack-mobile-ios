//
//  HomeViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 09/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import TimelineTableViewCell

class EventsViewController: UIViewController { //UserDataHandler {

    // MARK: UI

    // General properties
    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Logout segue -- logout user before loading login view
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.logout()
        }

    }

}
