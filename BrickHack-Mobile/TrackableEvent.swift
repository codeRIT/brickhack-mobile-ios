//
//  TrackableEvent.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 1/16/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import Foundation

final class TrackableEvent{
    
    var bandID: String?
    var createdAt: Date?
    var id: Int?
    var trackableTagID: Int?
    var userID: Int?
    var updatedAt: Date?
    
    init(bandID: String, createdAt: Date, id: Int, trackableTagID: Int, userID: Int, updatedAt: Date){
        self.bandID = bandID
        self.createdAt = createdAt
        self.id = id
        self.trackableTagID = trackableTagID
        self.userID = userID
        self.updatedAt = updatedAt
    }
    
}
