//
//  ResourcesViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/25/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2

class ResourcesViewController: UIViewController, UserDataProtocol {

    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!


    override func viewDidLoad() {
        super.viewDidLoad()

        print("ResourcesVC: userID of \(userID.description)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
