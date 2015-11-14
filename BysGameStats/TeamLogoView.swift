//
//  TeamLogoView.swift
//  BysGameStats
//
//  Created by James Tench on 11/10/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
let pi: CGFloat = CGFloat(M_PI)


@IBDesignable
class TeamLogoView: UIView {
    var outLineColor : UIColor = UIColor.whiteColor()
    // Base Blue = (0, 87, 176)
    var fillColor : UIColor = UIColor(red: 0, green: 87.0 / 255.0, blue: 176.0 / 255.0, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        let radius : CGFloat = max(bounds.width, bounds.height)
        
        let archWidth : CGFloat = 4
        let startAngle : CGFloat = 0
        let endAngle : CGFloat = 2 * pi
        
        let outlinePath = UIBezierPath(arcCenter: center, radius: radius / 2 - archWidth / 2 - 1, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        outlinePath.lineWidth = archWidth
        outLineColor.setStroke()
        outlinePath.stroke()
    }

}
