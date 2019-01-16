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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
