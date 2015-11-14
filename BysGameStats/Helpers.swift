//
//  Helpers.swift
//  BysGameStats
//
//  Created by James Tench on 10/23/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import Foundation
import UIKit

class Helpers{

    
    class func isValidEmail(email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: NSRegularExpressionOptions.CaseInsensitive)
        
        return regex.firstMatchInString(email, options: [], range: NSMakeRange(0, email.characters.count)) != nil
    }
    
    class func isValidTextField(textFieldText: String?) -> Bool {
        if let fieldText = textFieldText {
            let newText = fieldText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if newText.characters.count == 0 {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    
    class func setBorder(textField: UITextField, isValid: Bool) {
        textField.layer.cornerRadius = 8.0
        textField.layer.borderWidth = 1
        
        if !isValid {
            textField.layer.borderColor = UIColor.redColor().CGColor
        } else {
            textField.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    class func hideActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    class func showActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
}
