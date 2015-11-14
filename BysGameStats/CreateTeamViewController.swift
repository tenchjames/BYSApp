//
//  CreateTeamViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/21/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import CoreData
import Parse

class CreateTeamViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var leagueNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    var leagues = [League]()
    var selectedLeague : League?
    var teamColor: String?
    
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
        if let selectedLeague = self.selectedLeague {
            leagueNameLabel.text = selectedLeague.leagueName
        }
        changeColor()
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

    @IBAction func changeColor() {
        let r: CGFloat = CGFloat(redSlider.value / 255.0)
        let g: CGFloat = CGFloat(greenSlider.value / 255.0)
        let b: CGFloat = CGFloat(blueSlider.value / 255.0)
        
        teamColor = "\(redSlider.value)|\(greenSlider.value)|\(blueSlider.value)"
        colorView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func isValidLeague() -> Bool {
        return selectedLeague != nil
    }
    
    func isValidTeamName() -> Bool {
        return Helpers.isValidTextField(teamName.text)
    }
    
    func isValidForm() -> Bool {
        if !isValidLeague() {
            return false
        }
        
        if !isValidTeamName() {
            Helpers.setBorder(teamName, isValid: false)
            return false
        }
        
        Helpers.setBorder(teamName, isValid: true)
        return true
    }
    
    func validateForm() {
        if isValidForm() {
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
        }
    }

    @IBAction func submitNewTeam() {
        Helpers.showActivityIndicator(activityIndicator)
        // should be valid if submitting it passed validation tests
        guard let selectedLeague = selectedLeague else {
            return
        }
        
        let name = teamName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let pointer = PFObject(className: "League")
        pointer.objectId = selectedLeague.objectId
        
        let teamQuery = PFQuery(className: "Team")
        teamQuery.whereKey("teamName", equalTo: name)
        teamQuery.whereKey("league", equalTo: pointer)
        teamQuery.findObjectsInBackgroundWithBlock() { results, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error checking if this team currently exists", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if let results = results {
                    if results.count > 0 {
                        let ac = UIAlertController(title: "Unable to Add", message: "Sorry a league with these attributes already exists", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    } else {
                        // ok to save the team
                        let newTeam = PFObject(className: "Team")
                        newTeam["teamName"] = name
                        newTeam["league"] = pointer
                        newTeam["teamColor"] = self.teamColor!
                        newTeam.saveInBackgroundWithBlock() { result, error in
                            if let _ = error {
                                let ac = UIAlertController(title: "Error", message: "Sorry there was an error saving the team", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            } else {
                                let dict = [
                                    "objectId" : newTeam.objectId!,
                                    "teamName" : name,
                                    "league" : selectedLeague,
                                    "teamColor" : self.teamColor!,
                                    "gamesWon" : 0,
                                    "gamesLost" : 0,
                                    "gamesTied" : 0
                                ]

                                let _ = Team(dictionary: dict, context: self.sharedContext)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.stackManager.saveContext()
                                }

                                let ac = UIAlertController(title: "Success", message: "The New Team has been added!", preferredStyle: .Alert)
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
