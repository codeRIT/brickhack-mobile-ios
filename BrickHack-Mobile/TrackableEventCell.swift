//
//  TrackableEventCell.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 1/16/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit

class TrackableEventCell: UITableViewCell {

    @IBOutlet weak var trackableEventLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    let dateFormatter = DateFormatter()
    
    func setTrackableEventData(label: String, updatedAt: Date){
        dateFormatter.dateFormat = "h:mm a"
        trackableEventLabel.text = label
        updatedAtLabel.text = dateFormatter.string(from: updatedAt)
    }

}
