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
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let parseClient = ParseClient.sharedInstance
    let coreDataContext = CoreDataContext.sharedInstance
    
    var primaryLeagueId: String?
    var primaryTeamId: String?
    var primaryLeague: League?
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("bysGameStatsArchive").path!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = PFUser.currentUser() {
            // if we have a current parse user then get updated
            // then we know the user has saved in core data
            // retrieve user info from core data and transtion to the next
            // screen
            
            self.parseClient.getUserLeagueInfo(user) { result, error in
                // if we have a good result back from parse, persist it in coredata
                // so it can be used later in some offine fashion
                // else log the user in without league
                if let obj = result {
                    self.primaryLeague = self.parseClient.leagueFromPFObject(obj)
                }
                self.completeLogin()
            }
        } else {
            // else present the login screen and ask the user to get parse info
            let facebookLoginButton = FBSDKLoginButton()
            facebookLoginButton.delegate = self
            facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(facebookLoginButton)
            
            let facebookViewDictionary = ["facebookLoginButton" : facebookLoginButton]
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[facebookLoginButton]-10.0-|", options: [], metrics: nil, views: facebookViewDictionary))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[facebookLoginButton]-|", options: [], metrics: nil, views: facebookViewDictionary))
            
            facebookLoginButton.readPermissions = ["public_profile", "email"]
            
        }
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//    }
 
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let currentToken = FBSDKAccessToken.currentAccessToken() {
            let params = ["fields" :"id,name,email"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            graphRequest.startWithCompletionHandler() { connection, result, error in
                print(result)
            }
            PFFacebookUtils.logInInBackgroundWithAccessToken(currentToken) { user, error in
                if let user = user {
                    self.parseClient.getUserLeagueInfo(user) { result, error in
                        // if we have a good result back from parse, persist it in coredata
                        // so it can be used later in some offine fashion
                        // else log the user in without league
                        if let obj = result {
                            self.primaryLeague = self.parseClient.leagueFromPFObject(obj)
                        }
                        self.completeLogin()
                    }
                } else {
                    print("Uh oh. The user cancelled the Facebook login.")
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    
    func completeLogin() {
        // use core data to login
        // parse updates core data, the it can be used in the app
        // even if the app is offline
        // todo, only query parse when needed (add some code to test)
        dispatch_async(dispatch_get_main_queue()) {
            //self.getUserDefaults()
            let rootController = self.storyboard!.instantiateViewControllerWithIdentifier("RootNavigationController") as! UINavigationController
            let controller = rootController.topViewController as! LeagueViewController
            controller.primaryLeague = self.primaryLeague
            self.presentViewController(rootController, animated: true
                , completion: nil)
            }
    }

//    func storeUserLeagueData(obj: PFObject) {
//        let dict = [
//            "objectId" : obj.objectId,
//            "year" : obj["year"],
//            "updatedAt" : obj.updatedAt,
//            "leagueType" : obj["leagueType"],
//            "ageGroup" : obj["ageGroup"],
//            "leagueName" : obj["leagueName"],
//            "commissionerEmail" : obj["commissionerEmail"]
//        ]
//        // store the data we got from parse in core data so app can be
//        // used offline if user is not connected to the internet
//        
//        if let coredataLeague = self.coreDataContext.getLeagueIdByObjectId(obj.objectId!) as? League {
//            dispatch_async(dispatch_get_main_queue()) {
//                self.primaryLeague = coredataLeague
//                coredataLeague.updateObject(dict)
//                self.stackManager.saveContext()
//            }
//        } else {
//            dispatch_async(dispatch_get_main_queue()) {
//                self.primaryLeague = League(dictionary: dict, context: self.sharedContext)
//                self.stackManager.saveContext()
//            }
//        }
//    }
    
    @IBAction func loginWithUserNameButtonTouchUp(sender: AnyObject) {
        let userName = userNameField.text!
        let password = passwordTextField.text!
        PFUser.logInWithUsernameInBackground(userName, password: password) { user, error in
            if let error = error {
                print(error.userInfo["error"])
            } else {
                if let user = user {
                    self.parseClient.getUserLeagueInfo(user) { result, error in
                        // if we have a good result back from parse, persist it in coredata
                        // so it can be used later in some offine fashion
                        // else log the user in without league
                        if let obj = result {
                            self.primaryLeague = self.parseClient.leagueFromPFObject(obj)
                        }
                        self.completeLogin()
                    }
                }
                // need else if we don't have a pf user ? add error message or something
            }
        }
    }
    
    // TODO: add a signup button
    
    //        var user = PFUser()
    //        user.username = "tenchjames"
    //        user.password = "[Jeff24Gordon]"
    //        user.email = "tenchjames@yahoo.com"
    //        // other fields can be set just like with PFObject
    //
    //        user.signUpInBackgroundWithBlock {
    //            (succeeded: Bool, error: NSError?) -> Void in
    //            if let error = error {
    //                let errorString = error.userInfo["error"] as? NSString
    //                // Show the errorString somewhere and let the user try again.
    //            } else {
    //                // Hooray! Let them use the app now.
    //            }
    //        }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

