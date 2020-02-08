//
//  AlertMessage.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 10/4/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import SwiftMessages


class MessageHandler {

    // A set of common message types
    // @TODO: Flesh these out as needed (error=red, warning=yellow, info=blue styles)
    // For now, only error is supported.
    enum MessageType {
        case error, warning, info
    }

    // Wrapper for SwiftMessages that configures standard properties for this project.
    // Precondition: must be called on the main thread
    static func showAlertMessage(withTitle title: String, body: String, type: MessageType ) {

        let view = MessageView.viewFromNib(layout: .tabView)

        // Map our fake type to their type
        switch type {
        case .error: view.configureTheme(.error)
        case .warning: view.configureTheme(.warning)
        case .info: view.configureTheme(.info)
        }
        
        view.button?.isHidden = true
        view.configureContent(title: title,
                              body: body,
                              iconText: "⚠️")

        // Tapping message will hide view
        view.tapHandler       = { _ in SwiftMessages.hide() }

        // Configure view properties
        // @TODO: Add progress bar timer, à-la Discord?
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.dimMode = .color(color: UIColor.black.withAlphaComponent(0.5), interactive: true)
        config.preferredStatusBarStyle = .lightContent
        config.duration = .automatic


        SwiftMessages.show(config: config, view: view)

    }

    static func showConnectionError() {
        print("ERROR: Connection Error")
        showAlertMessage(withTitle: "Unable To Connect",
                         body: "Make sure you're connected to the internet.",
                         type: .error)
    }

    static func showAuthorizationDeniedError(withText error: Error) {
        print("ERROR: Authorization Denied")
        print(error.localizedDescription)
        showAlertMessage(withTitle: "Authorization Denied",
                         body: "Please try again.",
                         type: .error)
    }

    static func showInvalidUserError() {
        print("ERROR: Invalid user")
        showAlertMessage(withTitle: "Invalid User",
                         body: "Please log in again.",
                         type: .error)
    }

    static func showAuthSigningError() {
        print("ERROR: Auth signing error")
        showAlertMessage(withTitle: "Authentication Error",
                         body: "Please try logging in again.",
                         type: .error)
    }

    static func showNetworkError(withText errorText: String) {
        print("ERROR: Network Error")
        print(errorText)
        showAlertMessage(withTitle: "Networking Error",
                         body: "Error grabbing user info from server.",
                         type: .error)
    }

    static func showUserDataParsingError(withText errorText: String = "") {
        print("ERROR: User Data Parsing Error")
        print(errorText)
        showAlertMessage(withTitle: "Parsing Error",
                         body: "Error parsing user info from server.",
                         type: .error)
    }

    static func showInvalidFavoriteButtonError() {
        print("ERROR: Attempted to favorite a non-favorite-button cell.")
        showAlertMessage(withTitle: "Unable to favorite",
                         body: "Please try again later.",
                         type: .error)
    }

    static func showUnableToOpenURLError(url: URL) {
        print("ERROR: URL \(url.absoluteString) cannot be opened.")
        showAlertMessage(withTitle: "URL cannot be opened.",
                         body: "Please try again later.",
                         type: .error)
    }

    static func showUnknownUserDataError() {
        print("ERROR: Could not find questionnaire for user.")
        showAlertMessage(withTitle: "User name unknown!",
                         body: "Setting a placeholder name in the meantime...",
                         type: .info)
    }
}
