//
//  HomeViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 09/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

// @TODO: Rename to "EventsViewController" maybe?
class EventsViewController: UIViewController, UserDataHandler {

    var oauthGrant: OAuth2ImplicitGrant!
    var userID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Logout segue -- logout user before loading login view
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.logout()
        }
    }

    // Set dark status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
