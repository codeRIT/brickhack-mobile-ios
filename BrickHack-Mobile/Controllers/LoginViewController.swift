//
//  LoginViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 9/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2
import Alamofire
import SwiftMessages


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

        guard !oauthGrant.isAuthorizing else {
            oauthGrant.abortAuthorization()
            return
        }

        // Update UI
        // @TODO: Maybe move to SVProgressHud, or a status label?
        // (Not a fan of changing UI like this; may break accessibility)
        sender.setTitle("Authorizing", for: UIControl.State.normal)
        sender.isEnabled = false

        oauthGrant.authConfig.authorizeEmbedded = true
        oauthGrant.authConfig.authorizeContext = self

        oauthGrant.authorize() { response, error in
            print("Authorizing...")

            // @TODO: Case-by-case error handling would be great here.
            guard error == nil else {
                print("Authorization denied.")
                print("Error: \(error!)")
                self.resetLoginButton(sender)
                return
            }

            if self.oauthGrant.hasUnexpiredAccessToken() {
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
    var oauthGrant = OAuth2ImplicitGrant(settings: [
        "client_id": "745251411cbd86b08c69c7c504f83a319ea60bc0253e6ad9e9953f536d2c3003",
        "authorize_uri": Routes.authorize,
        "redirect_uris": ["brickhack-ios://oauth/callback"],
        "scope": ""] as OAuth2JSON)


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Once the view appears and a valid token exists, take the user directly into the app without having to press login
    override func viewDidAppear(_ animated: Bool) {
        if hasInternetAccess() {
            if oauthGrant.hasUnexpiredAccessToken() {
//                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }
        }
    }


    // MARK: Functions

    // Resets login button text back to default after displaying "authorizing"
    // @TODO: Maybe move to SVProgressHud, or a status label?
    // (Not a fan of changing UI like this; may break accessibility)
    func resetLoginButton(_ sender: UIButton) {
        sender.setTitle("Login", for: UIControl.State.normal)
        sender.isEnabled = true
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "authSuccessSegue") {

            // Pass oauth instance forward, grab user data
            if let homeVC = segue.destination.children.first as? HomeViewController {

                // Get user data
//                homeVC.userData = getUserData()
                getUserData()
                homeVC.oauthGrant = self.oauthGrant

            }
        }
    }

    func getUserData() {

        // Request user info
        var request = URLRequest(url: URL(string: Routes.currentUser)!)

        // @TODO: 401 redirect cycle vs. this implementation?
        // Current plan is to use this token throughout the app, and guaruntee authorization
        // from this point forward.
        do {
            try request.sign(with: OAuth2DataLoader(oauth2: oauthGrant).oauth2)
        } catch {
            print("User login sign request error: \(error.localizedDescription)")
            MessageHandler.showAlertMessage(withTitle: "Login Error",
                                            body: "Unable to grab user data from server.",
                                            type: .error)
            return
        }

        Alamofire.request(request).validate().responseJSON { (response) in
            print(response)
            // @TODO: Return data to flow
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