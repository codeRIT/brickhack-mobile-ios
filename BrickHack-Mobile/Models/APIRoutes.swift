//
//  APIRoutes.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 9/30/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Define global constants for API routes

// Note: OAuth requires SSH/TLS on all connections.
// For local development, route through ngrok,
// and set App Transpot to allow localhost in info.plist
struct Routes {
    static let environment           = "https://hm.baudouin.io"
    static let authorize             = "\(environment)/oauth/authorize"
    static let currentUser           = "\(environment)/oauth/token/info"
    static let questionnaire         = "\(environment)/apply.json"
    static let resetPassword         = "\(environment)/users/password/new"

}

// Define a NetworkReachabilityManager so the app can determine if the user has a connection before attempting to connect to the internet
// (Possiblly factor to its own struct for better global style?)
let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: Routes.environment)
