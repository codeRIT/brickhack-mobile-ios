//
//  User.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 2/3/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import Foundation

// User model
struct User: Decodable {

    var firstName: String
    var lastName: String
    // @TODO: School name

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    init() {
        self.init(firstName: "", lastName: "")
    }

    // Map underscored JSON values into camelCase in this code
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}


