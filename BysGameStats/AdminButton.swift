//
//  AdminButton.swift
//  BysGameStats
//
//  Created by James Tench on 10/31/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit

class AdminButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor(red: 227 / 255.0, green: 96 / 255.0, blue: 23 / 255.0, alpha: 1.0)
        layer.borderColor = tintColor.CGColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        contentEdgeInsets = UIEdgeInsetsMake(5.0, 15.0, 5.0, 15.0);
    }
}
