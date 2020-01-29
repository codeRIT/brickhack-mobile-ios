//
//  FavoriteButton.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 1/27/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {

    var section: Int?
    var row: Int?
    override var isSelected: Bool {
        didSet {
            self.toggle()
        }
    }

    // Selected state things are not working out, so this is the best solution for now.
    func toggle() {
        if isSelected {
            self.setImage(UIImage(named: "filledStar"), for: .normal)
        } else {
            self.setImage(UIImage(named: "emptyStar"), for: .normal)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
