//
//  VSRoundView.swift
//  BysGameStats
//
//  Created by James Tench on 11/1/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit

class VSRoundView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 25.0
        layer.backgroundColor = UIColor(red: 0 / 255.0, green: 87 / 255.0, blue: 176 / 255.0, alpha: 1.0).CGColor
    }

}
