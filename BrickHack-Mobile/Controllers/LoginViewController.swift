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
import SafariServices


// Defines the set of information needed to handle user data for any given class.
// Note that LoginViewController does not conform to this protocol despite handling user data,
// as it needs a computed property to get/set the userID, while all other classes do not require
// this functionality.
protocol UserDataHandler {
    var userID: Int! { get set }
    var oauthGrant: OAuth2ImplicitGrant! { get set }
    // @TODO: Add user data info upon backend implementation
    // let userData: [String, Any] { get set }
}


class LoginViewController: UIViewController {

    // MARK: IB Properties
    @IBOutlet weak var loginButton: UIButton?


    // MARK: IB Actions

    // Initiates the OAuth process if no valid token found
    @IBAction func initializeOAuth(_ sender: UIButton) {

        // Check for internet
        guard hasInternetAccess() else {
            MessageHandler.showConnectionError()
            return
        }

        // Set authorization method
        oauthGrant.authConfig.authorizeEmbedded = true
        oauthGrant.authConfig.authorizeContext = self

        // Authorize the user
        oauthGrant.authorize() { response, error in

            print("Authorizing...")

            // Check if auth error
            guard error == nil else {

                // Only show error if not error 29 (user-cancelled login)
                if (!error!.localizedDescription.contains("29")) {
                    MessageHandler.showAuthorizationDeniedError(withText: error!)
                }
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

    @IBAction func forgotPassword(_ sender: Any) {
        let safariVC = SFSafariViewController(url: URL(string: Routes.resetPassword)!)
        self.present(safariVC, animated: true, completion: nil)
    }

    // Need to escape UINavigationController when "Logout" is tapped
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}


    // MARK: Properties

    var oauthGrant = OAuth2ImplicitGrant(settings: [
        "client_id": "745251411cbd86b08c69c7c504f83a319ea60bc0253e6ad9e9953f536d2c3003",
        "authorize_uri": Routes.authorize,
        "redirect_uris": ["brickhack-ios://oauth/callback"],
        "scope": ""] as OAuth2JSON)

    // @TODO: Nonexistent value is 0 by default, maybe wrap somehow to nil?
    var userID: Int {
        get {
            return UserDefaults.standard.integer(forKey: "userID")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Once the view appears and a valid token exists, take the user directly into the app without having to press login
    override func viewDidAppear(_ animated: Bool) {
        if hasInternetAccess() {

            // Only continue automatically if authenticated, AND user data is persisted
            if oauthGrant.hasUnexpiredAccessToken() && userID != 0 {

                // Continue to main app if authorized, don't show spinner
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }
        }
    }


    // MARK: Functions

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "authSuccessSegue") {

            // Check for MainTabBarController (skip through nav controller)
            if let tabVC = segue.destination.children.first! as? MainTabBarController {

                // Check if valid user (on error, user will reauth)
                guard userID != 0 else {
                    MessageHandler.showInvalidUserError()
                    return
                }

                // Pass data to the tab bar controller, which will handle passing its own children
                tabVC.userID = userID
                tabVC.oauthGrant = oauthGrant
            }
        }
    }


    // MARK: User data & login flow

    func loginFlow() {

        // Generate signed request for userID
        let idRequest = signURLRequest(withRoute: Routes.currentUser)
        guard let signedIDRequest = idRequest else {
            DispatchQueue.main.async {
                MessageHandler.showAuthSigningError()
            }
            return
        }

        // Generate signed request for username
        // (user id is added in network chain)
        let nameRequest = signURLRequest(withRoute: Routes.questionnaire)
        guard var signedNameRequest = nameRequest else {
            DispatchQueue.main.async {
                MessageHandler.showAuthSigningError()
            }
            return
        }

        // Show spinner before network activity
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }

        // Networking!
        // First, grab the user id from teh server.
        URLSession.shared.dataTask(with: signedIDRequest) { (data, response, error) in

            guard error == nil else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: error!.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: error!.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                return
            }

            // Convert server data to JSON
            var json: [String: Any]
            do {
                json = try JSON(data: data).dictionaryObject!
            } catch {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: error.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                return
            }

            // Grab our integer from it
            let userIDConverted = json["resource_owner_id"] as? Int

            // Check cast
            guard let userID = userIDConverted else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: error!.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                return
            }

            // Save userID
            UserDefaults.standard.set(userID, forKey: "userID")
            print("userID: \(userID)")

            // @FIXME: Bypass name functionality for now
            // Segue to main app
            self.performSegue(withIdentifier: "authSuccessSegue", sender: self)

            // Now that we have the user ID, append it and
            // request the user info.
            signedNameRequest.url?.appendPathComponent("\(userID).json")
            signedNameRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // Note: spinner is still visible!
            URLSession.shared.dataTask(with: signedNameRequest) { (data, response, error) in

                guard error == nil else {
                    DispatchQueue.main.async {
                        MessageHandler.showNetworkError(withText: error!.localizedDescription)
                        SVProgressHUD.dismiss()
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        MessageHandler.showUserDataParsingError()
                        SVProgressHUD.dismiss()
                    }
                    return
                }

                // Check response code
                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        MessageHandler.showNetworkError(withText: httpResponse.statusString)
                        SVProgressHUD.dismiss()
                    }
                    return
                }

                // Convert server data to JSON
                var json: JSON

                do {
                    json = try JSON(data: data, options: .allowFragments)
                } catch {
                    DispatchQueue.main.async {
                        MessageHandler.showUserDataParsingError(withText: "Unable to convert JSON")
                        SVProgressHUD.dismiss()
                    }
                    return
                }

                // @FIXME
                // Hello, Developer.
                // At this point, the code should have errored out.
                // The backend has not implemented the functionality needed for the preivous code to work.
                // But, just in case something happens, this should do it.
                DispatchQueue.main.async {
                    MessageHandler.showUserDataParsingError()
                    SVProgressHUD.dismiss()
                }

                return


                // This is some debugging code for the time being, that will not be reached:
                let contents = String(data: data, encoding: .ascii)
                print(json)
                print(contents!)
                print("JSON data:")

            }.resume()
        }.resume()

    }

    // Signs a route request with a current/valid auth key.
    func signURLRequest(withRoute route: String) -> URLRequest? {

        var request = URLRequest(url: URL(string: route)!)

        // @TODO: 401 redirect cycle vs. this implementation?
        do {
            try request.sign(with: OAuth2DataLoader(oauth2: oauthGrant).oauth2)
        } catch {
            DispatchQueue.main.async {
                MessageHandler.showAuthSigningError()
            }
            return nil
        }

        return request
    }

    // Set dark status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    //  MARK: Helper functions

    // Check if the device currently has access to the internet, and can establish a connection to the environment
    func hasInternetAccess() -> Bool {
        guard let isReachable = networkReachabilityManager?.isReachable else {
            return false
        }

        return isReachable
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
