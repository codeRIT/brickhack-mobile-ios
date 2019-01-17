//
//  TrackableTag.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 1/16/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import Foundation

final class TrackableTag{
    
    var id: Int
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, name: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
