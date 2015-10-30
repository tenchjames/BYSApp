//
//  BackgroundView.swift
//  BysGameStats
//
//  Created by James Tench on 10/11/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    // An orange gradient background
    override func drawRect(rect: CGRect) {
        let darkerBlue: UIColor = UIColor(red: 31 / 255.0, green: 30 / 255.0, blue: 74 / 255.0, alpha: 1.0)
        let lighterBlue: UIColor = UIColor(red: 0 / 255.0, green: 87 / 255.0, blue: 176 / 255.0, alpha: 1.0)
        //let darkerBlue: UIColor = UIColor(red: 0.0, green: 0.341, blue: 0.690, alpha: 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        let blueGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [darkerBlue.CGColor, lighterBlue.CGColor], [0,1])
        
        let backgroundPath = UIBezierPath(rect: CGRectMake(0, 0, self.frame.width, self.frame.height))
        CGContextSaveGState(context)
        backgroundPath.addClip()
        
        let options = CGGradientDrawingOptions([CGGradientDrawingOptions.DrawsBeforeStartLocation, CGGradientDrawingOptions.DrawsAfterEndLocation])
        
        CGContextDrawLinearGradient(context, blueGradient, CGPointMake(160, 0), CGPointMake(160, 568),options)
        CGContextRestoreGState(context)
    }
    
    
}