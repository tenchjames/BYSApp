//
//  CreateCoachViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/24/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CreateCoachViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var coachNameField: UITextField!
    @IBOutlet weak var coachEmailField: UITextField!
    @IBOutlet weak var coachCellPhoneField: UITextField!
    @IBOutlet weak var isHeadCoachSlider: UISwitch!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var leagueLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let parseClient = ParseClient.sharedInstance
    let coreDataContext = CoreDataContext.sharedInstance
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    
    var selectedLeague : League?
    var selectedTeam : Team?

    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.enabled = false
        if let league = selectedLeague {
            leagueLabel.text = league.leagueName
        }
        if let team = selectedTeam {
            teamLabel.text = team.teamName
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Helpers.hideActivityIndicator(activityIndicator)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // change the value here then validate the new value
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        textField.text = newText as String
        validateForm()
        return false
    }
    
    func validateForm() {
        if isValidForm() {
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
        }
    }
    
    func isValidForm() -> Bool {
        if !isValidCoachName() {
            Helpers.setBorder(coachNameField, isValid: false)
            return false
        }
        Helpers.setBorder(coachNameField, isValid: true)
        
        if !isValidCoachEmail() {
            Helpers.setBorder(coachEmailField, isValid: false)
            return false
        }
        Helpers.setBorder(coachEmailField, isValid: true)
        
        if !isValidCellPhone() {
            Helpers.setBorder(coachCellPhoneField, isValid: false)
            return false
        }
        Helpers.setBorder(coachCellPhoneField, isValid: true)
        return true
    }
    
    
    func isValidCoachName() -> Bool {
        return Helpers.isValidTextField(coachNameField.text)
    }
    
    func isValidCoachEmail() -> Bool {
        guard let email = coachEmailField.text else {
            return false
        }
        return Helpers.isValidEmail(email)
    }
    
    func isValidCellPhone() -> Bool {
        return Helpers.isValidTextField(coachCellPhoneField.text)
    }
    
    @IBAction func submitNewCoach() {
        Helpers.showActivityIndicator(activityIndicator)
        guard let selectedTeam = selectedTeam else {
            return
        }
        let selectedTeamId = selectedTeam.objectId
        guard let selectedLeague = selectedLeague else {
            return
        }
        let selectedLeagueId = selectedLeague.objectId
        guard var coachEmail = coachEmailField.text else {
            return
        }
        guard var coachName = coachNameField.text else {
            return
        }
        guard var coachCellPhone = coachNameField.text else {
            return
        }
        
        coachName = coachName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        coachEmail = coachEmail.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        coachCellPhone = coachCellPhone.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let isHeadCoach = isHeadCoachSlider.on
        
        let leaguePointer = PFObject(className: "League")
        leaguePointer.objectId = selectedLeagueId
        let teamPointer = PFObject(className: "Team")
        teamPointer.objectId = selectedTeamId
        
        let coachQuery = PFQuery(className: "Coach")
        coachQuery.whereKey("league", equalTo: leaguePointer)
        coachQuery.whereKey("teamCoaching", equalTo: teamPointer)
        coachQuery.whereKey("coachEmail", equalTo: coachEmail)
        coachQuery.findObjectsInBackgroundWithBlock() { results, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error checking if this coach currently exists", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if let results = results {
                    if results.count > 0 {
                        let ac = UIAlertController(title: "Unable to Add", message: "Sorry a coach with these attributes already exists", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    } else {
                        // ok to save new coach
                        let newCoach = PFObject(className: "Coach")
                        newCoach["coachName"] = coachName
                        newCoach["coachEmail"] = coachEmail
                        newCoach["cellPhoneNumber"] = coachCellPhone
                        newCoach["isHeadCoach"] = isHeadCoach
                        newCoach["teamCoaching"] = teamPointer
                        newCoach["league"] = leaguePointer
                        newCoach.saveInBackgroundWithBlock() { result, error in
                            if let _ = error {
                                let ac = UIAlertController(title: "Error", message: "Sorry there was an error saving the coach", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            } else {
                                // if success persist in coredata
                                let dict = [
                                    "objectId" : newCoach.objectId!,
                                    "coachName" : coachName,
                                    "coachEmail" : coachEmail,
                                    "cellPhoneNumber": coachCellPhone,
                                    "isHeadCoach" : isHeadCoach,
                                    "teamCoaching" : selectedTeam,
                                    "league" : selectedLeague
                                ]
                                let _ = Coach(dictionary: dict, context: self.sharedContext)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.stackManager.saveContext()
                                }
                                
                                let ac = UIAlertController(title: "Success", message: "The New Coach has been added!", preferredStyle: .Alert)
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