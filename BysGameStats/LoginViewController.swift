//
//  ViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/7/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import CoreData
import Parse
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let parseClient = ParseClient.sharedInstance
    let coreDataContext = CoreDataContext.sharedInstance
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = PFUser.currentUser() {
            self.completeLogin()
        } else {
            let logInController = BYSPFLoginViewController()
            logInController.delegate = self
            let signUpController = BYSPFSignupViewController()
            signUpController.delegate = self
            logInController.signUpController = signUpController
            logInController.facebookPermissions = ["public_profile"]
            logInController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.Facebook, PFLogInFields.SignUpButton, PFLogInFields.LogInButton]
            self.presentViewController(logInController, animated:true, completion: nil)
        }
    }

    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: completeLogin)
    }

    func completeLogin() {
        dispatch_async(dispatch_get_main_queue()) {
            let tabController = self.storyboard!.instantiateViewControllerWithIdentifier("LeagueRootController") as! UITabBarController
            tabController.navigationItem.hidesBackButton = true
            if let leaguePreference = Helpers.getLeaguePreference() {
                if let savedLeagueId = leaguePreference["primaryLeague"] as? String {
                    // get the league out of core data
                    if let savedLeague = CoreDataContext.sharedInstance.getLeagueIdByObjectId(savedLeagueId) {
                        let leagueController = tabController.viewControllers?.first as! LeagueViewController
                        leagueController.primaryLeague = savedLeague
                    }
                }
            }
            self.navigationController?.pushViewController(tabController, animated: true)
        }
    }
}