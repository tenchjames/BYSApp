//
//  CreateLeagueViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/23/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CreateLeagueViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var leagueName: UITextField!
    @IBOutlet weak var leagueType: UITextField!
    @IBOutlet weak var ageGroup: UITextField!
    @IBOutlet weak var commissionerEmail: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
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
        submitButton.enabled = false
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Helpers.hideActivityIndicator(activityIndicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
    }
    
    // MARK: - Keyboard Fixes
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // change the value here then validate the new value
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        textField.text = newText as String
        validateForm()
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validateForm() {
        if isValidForm() {
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
        }
    }

    func isValidForm() -> Bool {
        if !isValidLeagueName() {
            Helpers.setBorder(leagueName, isValid: false)
            return false
        }
        Helpers.setBorder(leagueName, isValid: true)
        
        if !isValidLeagueType() {
            Helpers.setBorder(leagueType, isValid: false)
            return false
        }
        Helpers.setBorder(leagueType, isValid: true)
        
        if !isValidAgeGroup() {
            Helpers.setBorder(ageGroup, isValid: false)
            return false
        }
        Helpers.setBorder(ageGroup, isValid: true)
        
        if !isValidYear() {
            Helpers.setBorder(yearTextField, isValid: false)
            return false
        }
        Helpers.setBorder(yearTextField, isValid: true)
        
        if !isValidEmail() {
            Helpers.setBorder(commissionerEmail, isValid: false)
            return false
        }
        Helpers.setBorder(commissionerEmail, isValid: true)
        return true
    }
    
    func isValidLeagueName() -> Bool {
        return Helpers.isValidTextField(leagueName.text)
    }
    
    func isValidLeagueType() -> Bool {
        return Helpers.isValidTextField(leagueType.text)
    }
    
    func isValidAgeGroup() -> Bool {
        return Helpers.isValidTextField(ageGroup.text)
    }
    
    func isValidEmail() -> Bool {
        if !Helpers.isValidTextField(commissionerEmail.text) {
            return false
        }
        return Helpers.isValidEmail(commissionerEmail.text!)
    }
    
    func isValidYear() -> Bool {
        if !Helpers.isValidTextField(yearTextField.text) {
            return false
        }
        
        guard let possibleNumber = Int(yearTextField.text!) else {
            return false
        }
        
        // being ambitious...if this app is here in 20 years we can updated it
        if possibleNumber < 2015 || possibleNumber > 2035 {
            return false
        }
        
        return true
    }
    
    @IBAction func submitNewLeague() {
        Helpers.showActivityIndicator(activityIndicator)
        // text fields should have been validated. trim whitespace for database insert
        let year = yearTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let league = leagueType.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let group = ageGroup.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let email = commissionerEmail.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let name = leagueName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // first check if that league already exists
        let leagueQuery = PFQuery(className: "League")
        leagueQuery.whereKey("year", equalTo: Int(year)!)
        leagueQuery.whereKey("leagueType", equalTo: league)
        leagueQuery.whereKey("ageGroup", equalTo: group)
        leagueQuery.whereKey("commissionerEmail", equalTo: email)
        leagueQuery.whereKey("leagueName", equalTo: name)
        
        leagueQuery.findObjectsInBackgroundWithBlock() { result, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error checking if this league currently exists", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if let result = result {
                    if result.count > 0 {
                        let ac = UIAlertController(title: "Unable to Add", message: "Sorry a league with these attributes already exists", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    } else {
                        // ok to save
                        let newLeague = PFObject(className: "League")
                        newLeague["year"] = Int(year)!
                        newLeague["leagueType"] = league
                        newLeague["ageGroup"] = group
                        newLeague["commissionerEmail"] = email
                        newLeague["leagueName"] = name
                        newLeague.saveInBackgroundWithBlock() { result, error in
                            if let _ = error {
                                let ac = UIAlertController(title: "Error", message: "Sorry there was an error saving the league", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            } else {
                                let dict : [String: AnyObject] = [
                                    "objectId" : newLeague.objectId!,
                                    "year" : Int(year)!,
                                    "leagueType" : league,
                                    "ageGroup" : group,
                                    "commissionerEmail" : email,
                                    "leagueName" : name
                                ]
                                
                                let _ = League(dictionary: dict, context: self.sharedContext)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.stackManager.saveContext()
                                }

                                let ac = UIAlertController(title: "Success", message: "The New League has been added!", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        Helpers.hideActivityIndicator(activityIndicator)
    }
}
