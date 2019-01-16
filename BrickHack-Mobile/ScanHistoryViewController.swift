//
//  ScanHistoryViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 1/16/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import OAuth2
import Alamofire

class ScanHistoryViewController: UIViewController {

    var oauth2: OAuth2ImplicitGrant?
    var sessionManager: SessionManager?
    var currentUser: Int?
    let currentUserAPI = "https://staging.brickhack.io/oauth/token/info"
    let tagsAPI = ""
    
    override func viewDidLoad() {
        sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        sessionManager!.request(currentUserAPI).validate().responseJSON{ response in
            let _  = self.sessionManager
            let dict = response.result.value as! [String: Any]
            self.currentUser = dict["resource_owner_id"] as? Int
            
        }
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
