//
//  LoginViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 9/27/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2
import SwiftyJSON
import SVProgressHUD


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
                // @FIXME: "NavController on SFViewController, whose view is not in the window hierarchy!"
                self.loginFlow()

            }
        }
    }

    // Need to escape UINavigationController when "Logout" is tapped
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}


    // MARK: Properties

    // @TODO: Convert to OAuth2PasswordGrant to use native login
    var oauthGrant = OAuth2ImplicitGrant(settings: [
        "client_id": "745251411cbd86b08c69c7c504f83a319ea60bc0253e6ad9e9953f536d2c3003",
        "authorize_uri": Routes.authorize,
        "redirect_uris": ["brickhack-ios://oauth/callback"],
        "scope": ""] as OAuth2JSON)
    var userID: Int? {
        get {
            return UserDefaults.standard.integer(forKey: "userID")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Once the view appears and a valid token exists, take the user directly into the app without having to press login
    // @TODO: Add UI feedback for this; success MessageHandler?
    override func viewDidAppear(_ animated: Bool) {
        if hasInternetAccess() {

            // Only continue if authenticated, AND user data is persisted
            if oauthGrant.hasUnexpiredAccessToken() && userID != nil {

                // Continue to main app if authorized, don't show spinner
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
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

                // @FIXME: Move loading here to account for grabbing of this data
                guard userID != nil else {
                    print("Invalid userID")
                    return
                }

                homeVC.userID = userID
                homeVC.oauthGrant = self.oauthGrant

            }
        }
    }

    // MARK: User data & login flow

    func loginFlow() {

        // Show spinner
        SVProgressHUD.show()

        // Generate signed request for userID
        let idRequest = signURLRequest(withRoute: Routes.currentUser)
        guard let signedIDRequest = idRequest else {
            MessageHandler.showAlertMessage(withTitle: "Auth error", body: "Unable to sign user ID auth request.", type: .error)
            return
        }

        // Generate signed request for username
        // (user id is added in promise)
        let nameRequest = signURLRequest(withRoute: Routes.questionnaire)
        guard var signedNameRequest = nameRequest else {
            MessageHandler.showAlertMessage(withTitle: "Auth error", body: "Unable to sign user name auth request.", type: .error)
            return
        }

        // Function for error checking
        func networkErrorCheck(_ error: Error) {
            print(error.localizedDescription)
            MessageHandler.showAlertMessage(withTitle: "Networking Error",
                                            body: "Error grabbing user id from server",
                                            type: .error)
        }

        // Networking!
        URLSession.shared.dataTask(with: signedIDRequest) { (data, response, error) in

            guard error == nil else {
                print("Error getting userID")
                networkErrorCheck(error!)
                return
            }

            guard let data = data else {
                print("Error getting data")
                networkErrorCheck(error!)
                return
            }

            // Convert server data to JSON
            var json: [String: Any]
            do {
                json = try JSON(data: data).dictionaryObject!
            } catch {
                print("Invalid server json: \(error)")
                networkErrorCheck(error)
                return
            }

            // Grab our integer from it
            let userIDConverted = json["resource_owner_id"] as? Int

            // Check cast
            guard let userID = userIDConverted else {
                print("Error casting userID to int")
                networkErrorCheck(error!)
                return
            }


            // @FIXME: Store in UserDefaults
            UserDefaults.standard.set(userID, forKey: "userID")
            print("userID: \(userID)")

            // Hide spinner
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }

            // @FIXME: Bypass name functionality for now
            // Segue to main app
            self.performSegue(withIdentifier: "authSuccessSegue", sender: self)

        }.resume()




    }

    // Signs a route request with a current/valid auth key.
    func signURLRequest(withRoute route: String) -> URLRequest? {

        var request = URLRequest(url: URL(string: route)!)

        // @TODO: 401 redirect cycle vs. this implementation?
        do {
            try request.sign(with: OAuth2DataLoader(oauth2: oauthGrant).oauth2)
        } catch {
            print("User login sign request error: \(error.localizedDescription)")
            MessageHandler.showAlertMessage(withTitle: "Login Error",
                                            body: "Unable to grab user data from server.",
                                            type: .error)
            return nil
        }

        return request
    }


    //  MARK: Helper functions

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

    func logout() {

        // Clear tokens
        oauthGrant.forgetTokens()

        // Clear cookies in webview
        let storage = HTTPCookieStorage.shared
        storage.cookies?.forEach() { storage.deleteCookie($0) }

        // Clear saved userID
        UserDefaults.standard.removeObject(forKey: "userID")

        print("Logged out user.")
    }

}
