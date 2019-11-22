//
//  ResourcesViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

class ResourcesViewController: UIViewController, UserDataHandler {

    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!


    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
