//
//  MainNavigationViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

class MainTabBarController: UITabBarController, UserDataProtocol {

    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("loaded!")

        for childVC in children {
            print("iterating")
            if var userDataVC = childVC as? UserDataProtocol {
                print("pasing user id of \(userID) ")
                userDataVC.userID = userID
                userDataVC.oauthGrant = oauthGrant
            }
        }



    }

    override func viewDidAppear(_ animated: Bool) {
        print("appeared!")
    }
    

    // This class serves to exist as a mediator between the LoginViewController
    // and the child view controllers from this NavigationViewController.
    // In particular, the user data will be passed forward into each child view controller *here*,
    // rather than risking bloat in the LoginViewController, which should only be concenred
    // with sending the data *forward*, rather than to whom.


}
