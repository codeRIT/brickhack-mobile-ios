//
//  HomeViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 11/14/18.
//  Copyright © 2018 codeRIT. All rights reserved.
//

import UIKit
import OAuth2
import Alamofire

final class HomeViewController: UIViewController {
    
    var oauth2: OAuth2ImplicitGrant?
    var loader: OAuth2DataLoader?
    var elements = [UIAccessibilityElement]()
    var sessionManager: SessionManager?
    let confirmationsGroup = UIAccessibilityElement(accessibilityContainer: self)
    let applicationsGroup = UIAccessibilityElement(accessibilityContainer: self)
    let denialsGroup = UIAccessibilityElement(accessibilityContainer: self)
    
    @IBOutlet weak var confirmationsValue: UILabel!
    @IBOutlet weak var confirmationsLabel: UILabel!
    @IBOutlet weak var denialsValue: UILabel!
    @IBOutlet weak var denialsLabel: UILabel!
    @IBOutlet weak var applicationsValue: UILabel!
    @IBOutlet weak var applicationsLabel: UILabel!
    
    // Initializes data for VoiceOver and fetches quick stats from environment
    override func viewDidLoad(){
        // Load quick stats from environment
        sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        sessionManager!.request(todaysStatsDataRoute).validate().responseJSON{ response in
            let _  = self.sessionManager
            let dict = response.result.value as? [String: Any] ?? [:]
            
            let confirmations = dict["Confirmations"] as? Int ?? 0
            let applications = dict["Applications"] as? Int ?? 0
            let denials = dict["Denials"] as? Int ?? 0
            
            self.confirmationsValue.text = String(confirmations)
            self.applicationsValue.text = String(applications)
            self.denialsValue.text = String(denials)
        }
        print(oauth2!.refreshToken)
        confirmationsGroup.accessibilityLabel = "\(confirmationsValue.text ?? "Unable to fetch number") + \(confirmationsLabel.text ?? "cconfirmations")"
        confirmationsGroup.accessibilityFrameInContainerSpace = confirmationsValue.frame.union(confirmationsLabel.frame)
        elements.append(confirmationsGroup)
        
        applicationsGroup.accessibilityLabel = "\(applicationsValue.text ?? "Unable to fetch number") + \(applicationsLabel.text ?? "applications")"
        applicationsGroup.accessibilityFrameInContainerSpace = applicationsValue.frame.union(applicationsLabel.frame)
        elements.append(applicationsGroup)
        
        denialsGroup.accessibilityLabel = "\(denialsValue.text ?? "Unable to fetch number") + \(denialsLabel.text ?? "denials")"
        denialsGroup.accessibilityFrameInContainerSpace = denialsValue.frame.union(denialsLabel.frame)
        elements.append(denialsGroup)
    }
    
    // Clears tokens and sends user back to login
    @IBAction func logoutWasPressed(_ sender: UIButton) {
        oauth2?.forgetTokens()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }
    
    // Sends user to ScanTagViewController
    @IBAction func scanWasPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "scanViewSegue", sender: self)
    }
    
    // Sends user to ScanHistoryViewController
    @IBAction func scanHistoryWasPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeToScanHistorySegue", sender: self)
    }
    
    // Prepares the next view by supplying it with the OAuth2ImplicitGrant before segue initiates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "logoutSegue"){
            let login  = segue.destination as? LoginViewController
            login?.oauth2 = self.oauth2!
        }else if(segue.identifier == "scanViewSegue"){
            let scanView = segue.destination as? ScanTagViewController
            scanView?.oauth2 = self.oauth2!
        }else if(segue.identifier == "homeToScanHistorySegue"){
            let scanHistoryView = segue.destination as? ScanHistoryViewController
            scanHistoryView?.oauth2 = self.oauth2!
        }
    }
}
