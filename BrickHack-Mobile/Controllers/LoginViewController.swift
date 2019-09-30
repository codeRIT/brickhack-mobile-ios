//
//  LoginViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 9/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2


class LoginViewController: UIViewController {

    // MARK: IB Properties
    @IBOutlet weak var loginButton: UIButton?


    // MARK: IB Actions
    // Initiates the OAuth process if no valid token found
    @IBAction func initializeOAuth(_ sender: UIButton) {

        guard hasInternetAccess() else {
            displayNoNetworkAlert()
            return
        }

        guard !oauth2.isAuthorizing else {
            oauth2.abortAuthorization()
            return
        }

        // Update UI
        // @TODO: Maybe move to SVProgressHud, or a status label?
        // (Not a fan of changing UI like this; may break accessibility)
        sender.setTitle("Authorizing", for: UIControl.State.normal)
        sender.isEnabled = false

        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = self

        oauth2.authorize() { response, error in
            print("Authorizing...")

            // @TODO: Case-by-case error handling would be great here.
            guard error == nil else {
                print("Authorization denied.")
                print("Error: \(error!)")
                self.resetLoginButton(sender)
                return
            }

            if self.oauth2.hasUnexpiredAccessToken() {
                print("Authorization successful.")

                // If login is successful, continue to main app
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
                    self.resetLoginButton(sender)
                }
            }
        }
    }

    // Needed to escape UINavigationController when "Logout" is tapped
    // @TODO may not implement
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}

    // MARK: Properties

    // @TODO: Convert to OAuth2PasswordGrant to use native login
    var oauth2 = OAuth2ImplicitGrant(settings: [
        "client_id": "745251411cbd86b08c69c7c504f83a319ea60bc0253e6ad9e9953f536d2c3003",
        "authorize_uri": Routes.authorize,
        "redirect_uris": ["brickhack-ios://oauth/callback"],
        "scope": ""] as OAuth2JSON)

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // Once the view appears and a valid token exists, take the user directly into the app without having to press login
    override func viewDidAppear(_ animated: Bool) {
        if hasInternetAccess(){
            if oauth2.hasUnexpiredAccessToken(){
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }
        }
    }


    // MARK: Functions

    // Resets login button text back to default after displaying "authorizing"
    // @TODO: Maybe move to SVProgressHud, or a status label?
    // (Not a fan of changing UI like this; may break accessibility)
    func resetLoginButton(_ sender: UIButton){
        sender.setTitle("Login", for: UIControl.State.normal)
        sender.isEnabled = true
    }

    // Pass oauth instance forward
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "authSuccessSegue") {
            // @TODO: Pass oauth to menu view, *through Nav Controller*
            if let homeVC = segue.destination as? HomeViewController {
//                homeVC.oauth2 = self.oauth2

            }
        }
    }

    // Check if the device currently has access to the internet, and can establish a connection to the environment
    func hasInternetAccess() -> Bool {
        guard let isReachable = networkReachabilityManager?.isReachable else {
            return false
        }

        return isReachable
    }

    // Displays a network issue alert if device isn't connected to the internet or can't connect to environment
    func displayNoNetworkAlert() {
        let alertController = UIAlertController(title: "Network Issue",
                                                message: "An issue occured with your network. Please be sure you are connected to the internet.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
