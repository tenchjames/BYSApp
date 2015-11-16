//
//  BYSPFLoginViewController.swift
//  BysGameStats
//
//  Created by James Tench on 11/8/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import ParseUI

// TODO: custom login screen
class BYSPFLoginViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIImageView(image: UIImage(named: "logo"))
        self.logInView?.logo = view
        self.logInView?.backgroundColor = UIColor(red: 0 / 255.0, green: 87 / 255.0, blue: 176 / 255.0, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        if let logInView = self.logInView {
            let xPosition = CGFloat(0.0)
            let width = logInView.frame.width
            let height = logInView.frame.width / 2
            if let logo = logInView.logo {
                logo.frame = CGRectMake(xPosition, 60.0, logInView.frame.width, logInView.frame.width / 2.0)
            }
            if let username = logInView.usernameField {
                username.frame = CGRectMake(xPosition, height + 60, width, 40.0)
            }
            if let pword = logInView.passwordField {
                pword.frame = CGRectMake(xPosition, height + 100, width, 40.0)
            }
        }
    }
}
