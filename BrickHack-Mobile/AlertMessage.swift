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

        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.button?.setTitle("Dismiss", for: .normal)
        view.configureContent(title: title,
                              body: body,
                              iconText: "⚠️")

        // Tapping button or message will hide view
        view.buttonTapHandler = { _ in SwiftMessages.hide() }
        view.tapHandler       = { _ in SwiftMessages.hide() }

        // Configure view properties
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.duration = .forever

        SwiftMessages.show(config: config, view: view)
    }
}
