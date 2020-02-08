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
    var currentUser: User! { get set }
//    var userID: Int! { get set }
//    var oauthGrant: OAuth2ImplicitGrant! { get set }
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
        // SFSafariViewController is sandboxed, so we need to use
        // p2_Oauth2's *embedded* view for auth, which allows US to
        // reset cookies and prevent insta-login.
        // @TODO: This causes some layoutconstraint bugs maybe. Maybe.
        oauthGrant.authConfig.ui.useSafariView = false
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
        "scope": "Access-your-bricks"] as OAuth2JSON)

    // User model instance
    var currentUser: User?

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
            if oauthGrant.hasUnexpiredAccessToken() && currentUser != nil {

                print("currentUser: \(currentUser)")

                // Continue to main app if authorized, don't show spinner
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }
        }
    }


    // MARK: Functions

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "authSuccessSegue") {

            // Make the destination be fullscreen
            segue.destination.modalPresentationStyle = .fullScreen

            // Pass data forward (temp to main screen)
            if let eventsVC = segue.destination as? TabViewController {
                print("passed user object")
                eventsVC.currentUser = self.currentUser
            }


            // Check for MainTabBarController (skip through nav controller)
            // Note: not used!
            /*
            if let tabVC = segue.destination.children.first as? MainTabBarController {

                // Check if valid user (on error, user will reauth)
                guard userID != 0 else {
                    MessageHandler.showInvalidUserError()
                    return
                }

                // Pass data to the tab bar controller, which will handle passing its own children
                tabVC.userID = userID
                tabVC.oauthGrant = oauthGrant
            } */
        }
    }


    // MARK: User data & login flow

    func loginFlow() {

        // Generate signed request for username
        // (user id is added in network chain)
        let nameRequest = signURLRequest(withRoute: Routes.questionnaire)
        guard let signedNameRequest = nameRequest else {
            DispatchQueue.main.async {
                MessageHandler.showAuthSigningError()
            }
            return
        }

        // Show spinner before network activity
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }

        URLSession.shared.dataTask(with: signedNameRequest) { (data, response, error) in

            // MARK: Error checking
            guard error == nil else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: error!.localizedDescription)
                    SVProgressHUD.dismiss()
                    self.logout()
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    MessageHandler.showUserDataParsingError()
                    SVProgressHUD.dismiss()
                    self.logout()
                }
                return
            }

            // Check response code
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: "Invalid response code")
                    SVProgressHUD.dismiss()
                    self.logout()
                }
                return
            }

            guard httpResponse.statusCode != 404 else {
                DispatchQueue.main.async {
                    MessageHandler.showNetworkError(withText: "User account not found")
                    SVProgressHUD.dismiss()
                    self.logout()
                }
                return
            }


            // MARK: Data conversion

            // Convert server data to our User object
            do {
                self.currentUser = try JSONDecoder().decode(User.self, from: data)
            } catch (let error) {
                DispatchQueue.main.async {
                    print("parsing error: \(error)")
                    MessageHandler.showUserDataParsingError(withText: "Unable to convert JSON")
                    SVProgressHUD.dismiss()
                    self.logout()
                }
                return
            }

            // Now that we have the user data, go to the main screen,
            // passing the data forward!
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "authSuccessSegue", sender: self)
            }

            return

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
