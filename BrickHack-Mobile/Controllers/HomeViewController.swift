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
//    var userData: [Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print(oauthGrant.clientName ?? "No Client Name")
//        print(userData ?? "No user data")
    }

}