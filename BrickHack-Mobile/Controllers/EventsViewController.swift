//
//  HomeViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 09/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2
import TimelineTableViewCell

class EventsViewController: UIViewController { //UserDataHandler {


    // MARK: UI

    // General properties
    // @FIXME When login works
//    var oauthGrant: OAuth2ImplicitGrant!
//    var userID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Logout segue -- logout user before loading login view
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.logout()
        }

        // TableViewController segue
        // This is the main way to reference the ProfileTableViewCotroller
        // that is contained within this view via an Embed segue.
        if let tableVC = segue.destination as? ProfileTableViewController {

            // May just set properties as Strings;
            // this approach calls viewDidLoad() before this data is set,
            // which may lead to odd behavior down the road.
            tableVC.loadViewIfNeeded()

            // @FIXME: Fill using user data once login is working
            // (either here or in helper function or in previous VC)
            tableVC.nameLabel.text = "Aanya Schroeder"
            tableVC.schoolLabel.text = "University of Buffalo"

            // @TODO: Emoji picker for ImageView? Don't think backend supports images atm.


        }
    }

}
