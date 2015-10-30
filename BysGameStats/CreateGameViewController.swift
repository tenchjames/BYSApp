//
//  CreateGameViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/25/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CreateGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var homeTeam : Team?
    var awayTeam : Team?
    var selectedLeague: League?
    var dateScheduled : NSDate?
    let reuseIdentifier = "PickTeamCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var submitButton: UIButton!
    var teamNames = ["Select Home Team", "Select Away Team"]
    
    let coreDataContext = CoreDataContext.sharedInstance
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let homeTeam = homeTeam {
            teamNames[0] = homeTeam.teamName
        }
        if let awayTeam = awayTeam {
            teamNames[1] = awayTeam.teamName
        }
        if homeTeam == nil || awayTeam == nil {
            submitButton.enabled = false
        } else {
            submitButton.enabled = true
        }
        tableView.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = teamNames[indexPath.section]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        var controller : SelectTeamViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("SelectTeamViewController") as! SelectTeamViewController
        controller.selectedLeague = selectedLeague
        if indexPath.section == 0 {
            controller.exitAction = "GameReturnHomeTeam"
        } else {
            controller.exitAction = "GameReturnAwayTeam"
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Home Team"
        } else {
            return "Away Team"
        }
    }
    

    @IBAction func submitNewGame() {
        guard let homeTeam = homeTeam else {
            return
        }
        
        guard let awayTeam = awayTeam else {
            return
        }
        
        guard let selectedLeague = selectedLeague else {
            return
        }
        
        dateScheduled = datePicker.date
        // check if this game is already scheduled
        let homePointer = PFObject(className: "Team")
        homePointer.objectId = homeTeam.objectId
        let awayPointer = PFObject(className: "Team")
        awayPointer.objectId = awayTeam.objectId
        let leaguePointer = PFObject(className: "League")
        leaguePointer.objectId = selectedLeague.objectId
        
        let gameQuery = PFQuery(className: "Game")
        gameQuery.whereKey("leaguePointer", equalTo: leaguePointer)
        gameQuery.whereKey("homeTeamPointer", equalTo: homePointer)
        gameQuery.whereKey("awayTeamPointer", equalTo: awayPointer)
        gameQuery.whereKey("currentlyScheduledDate", equalTo: dateScheduled!)
        
        gameQuery.findObjectsInBackgroundWithBlock() {results, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error checking if this game currently exists", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if let results = results {
                    if results.count > 0 {
                        let ac = UIAlertController(title: "Unable to Add", message: "Sorry a game with these teams at that date & time already exists", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    } else {
                        // ok to save game
                        let newGame = PFObject(className: "Game")
                        newGame["homeTeamScore"] = 0
                        newGame["awayTeamScore"] = 0
                        newGame["originalScheduledDate"] = self.dateScheduled
                        newGame["currentlyScheduledDate"] = self.dateScheduled
                        newGame["leaguePointer"] = leaguePointer
                        newGame["homeTeamPointer"] = homePointer
                        newGame["awayTeamPointer"] = awayPointer
                        newGame.saveInBackgroundWithBlock() { results, error in
                            if let _ = error {
                                let ac = UIAlertController(title: "Error", message: "Sorry there was an error saving the game", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            } else {
                                // store the game in coredata
                                let dict = [
                                    "objectId" : newGame.objectId!,
                                    "homeTeamScore" : 0,
                                    "awayTeamScore" : 0,
                                    "originalScheduledDate" : self.dateScheduled!,
                                    "currentlyScheduledDate" : self.dateScheduled!,
                                    "league" : selectedLeague,
                                    "homeTeam" : homeTeam,
                                    "awayTeam" : awayTeam
                                ]
                                
                                let _ = Game(dict: dict, context: self.sharedContext)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.stackManager.saveContext()
                                }
                                let ac = UIAlertController(title: "Success", message: "The game was scheduled successfully!", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
































