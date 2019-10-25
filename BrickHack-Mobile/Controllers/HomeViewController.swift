//
//  HomeViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 09/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

class HomeViewController: UIViewController {

    var oauthGrant: OAuth2ImplicitGrant!
    var userID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("HomeVC: userID of \(userID.description)")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let loginVC = segue.destination as? LoginViewController {
            // Logout user before loading view
            loginVC.logout()
        }
    }

    // Set dark status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
