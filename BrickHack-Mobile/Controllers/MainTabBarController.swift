//
//  MainNavigationViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

class MainTabBarController: UITabBarController, UserDataHandler {

    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!

    override func viewDidLoad() {
        super.viewDidLoad()

        // This class serves to exist as a mediator between the LoginViewController
        // and the child view controllers from this TabBarController (bypassing NavigationViewController from LVC).
        // In particular, the user data will be passed forward into each child view controller *here*,
        // rather than risking bloat in the LoginViewController, which should only be concenred
        // with sending the data *forward*, rather than to whom.
        // (For some reason, not in prepareForSegue here.)
        for childVC in children {

            // Navigate through 0th navigation controller
            // (TabBar -> NavigationVC_0 -> VC0)
            if var userDataVC = childVC.children.first as? UserDataHandler {
                userDataVC.userID = userID
                userDataVC.oauthGrant = oauthGrant
            }
        }
    }
}
