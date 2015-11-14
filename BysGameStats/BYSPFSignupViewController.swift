//
//  BYSPFSignupViewController.swift
//  BysGameStats
//
//  Created by James Tench on 11/9/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import ParseUI

class BYSPFSignupViewController: PFSignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIImageView(image: UIImage(named: "logo"))
        self.signUpView?.logo = view
        self.signUpView?.backgroundColor = UIColor(red: 0 / 255.0, green: 87 / 255.0, blue: 176 / 255.0, alpha: 1.0)
    }
    
    override func viewDidLayoutSubviews() {
        if let logInView = self.signUpView {
            let xPosition = (logInView.frame.width - 150) / 2.0
            if let logo = logInView.logo {
                logo.frame = CGRectMake(xPosition, 80.0, 150, 146)
            }
        }
    }

}
