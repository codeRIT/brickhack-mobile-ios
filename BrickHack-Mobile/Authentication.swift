//
//  ViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 11/13/18.
//  Copyright © 2018 codeRIT. All rights reserved.
//

import UIKit
import OAuth2
import Alamofire

// Define global constants for API routes
let environment = "https://brickhack.io"
let authorizeRoute = "\(environment)/oauth/authorize"
let currentUserRoute = "\(environment)/oauth/token/info"
let todaysStatsDataRoute = "\(environment)/manage/dashboard/todays_stats_data"
let trackableTagsRoute = "\(environment)/manage/trackable_tags.json"
let trackableEventsRoute = "\(environment)/manage/trackable_events.json"
let editTrackableEventRoute = "\(environment)/manage/trackable_events/"
let trackableEventsRouteByUserRoute = "\(environment)/manage/trackable_events.json?trackable_event[user_id]="
// Define a NetworkReachabilityManager so the app can determine if the user has a connection before attempting to connect to the internet
let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: environment)

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton?
    // Creates an OAuth2ImplicitGrant object that will be passed between view controllers
    var oauth2 = OAuth2ImplicitGrant(settings: [
        "client_id": "745251411cbd86b08c69c7c504f83a319ea60bc0253e6ad9e9953f536d2c3003",
        "authorize_uri": authorizeRoute,
        "redirect_uris": ["brickhack-ios://oauth/callback"],
        "scope": ""] as OAuth2JSON)

    // Initiates the OAuth process if no valid token found
    @IBAction func initializeOAuth(_ sender: UIButton) {
        if hasInternetAccess(){
            if oauth2.isAuthorizing {
                oauth2.abortAuthorization()
                return
            }
            
            sender.setTitle("AUTHORIZING...", for: UIControl.State.normal)
            sender.isEnabled = false
            
            oauth2.authConfig.authorizeEmbedded = true
            oauth2.authConfig.authorizeContext = self
            
            //oauth2.logger = OAuth2DebugLogger(.trace)
            
            oauth2.authorize(){responce, error in
                print("Authorizing...")
                if error != nil{
                    self.didCancelOrFail(error, sender: sender)
                    print("Authorization denied.")
                }else if self.oauth2.hasUnexpiredAccessToken(){
                    print("Authorization successful.")
                    self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
                    self.resetLoginButton(sender)
                }
            }
        }else{
            displayNoNetworkAlert()
        }
    }
    
    // Used to catch any errors or cancellations during the authorization process
    func didCancelOrFail(_ error: Error?, sender: UIButton) {
        DispatchQueue.main.async {
            if let error = error {
                print("Authorization went wrong: \(error)")
            }
            self.resetLoginButton(sender)
        }
    }
    
    // Once the view appears and a valid token exists, take the user directly into the app without having to press login
    override func viewDidAppear(_ animated: Bool) {
        if hasInternetAccess(){
            if oauth2.hasUnexpiredAccessToken(){
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }
        }
    }
    
    // Resets login button text back to default after displaying "AUTHORIZING..."
    func resetLoginButton(_ sender: UIButton){
        sender.setTitle("LOGIN WITH BRICKHACK.IO »", for: UIControl.State.normal)
        sender.isEnabled = true
    }
    
    // Needed to escape UINavigationController when "Logout" is tapped
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    // Prepares the next view by supplying it with the OAuth2ImplicitGrant before segue initiates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "authSuccessSegue"){
            let navigationController  = segue.destination as! UINavigationController
            let menuView = navigationController.topViewController as? HomeViewController
            menuView?.oauth2 = self.oauth2
        }
    }
    
    // Used to determine if the device currently has access to the internet and can establish a connection to the environment
    func hasInternetAccess() -> Bool{
        if networkReachabilityManager?.isReachable ?? false{
            return true
        }else{
            return false
        }
    }
    
    // Displays a network issue alert if device isn't connected to the internet or can't connect to environment
    func displayNoNetworkAlert(){
        let alertController = UIAlertController(
            title: "Network Issue",
            message: "An issue occured with your network. Please be sure you are connected to the internet.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
