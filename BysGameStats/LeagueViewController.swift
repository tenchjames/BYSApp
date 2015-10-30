//
//  LeagueViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/18/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class LeagueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var leagueNameLabel: UILabel!
    @IBOutlet weak var commissionerNameLabel: UILabel!
    @IBOutlet weak var leagueAgeGroupLabel: UILabel!
    @IBOutlet weak var leagueTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var primaryLeague: League?
    var teams: [Team] = [Team]()
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
        // Do any additional setup after loading the view.
        // if a primary league is selected, show the details
        // else prompt the user to pick their primary league from a list
        if let primaryLeague = self.primaryLeague {
            leagueNameLabel.text = primaryLeague.leagueName
            commissionerNameLabel.text = primaryLeague.commissionerEmail
            leagueAgeGroupLabel.text = primaryLeague.ageGroup
            leagueTypeLabel.text = primaryLeague.leagueType
            getTeamsByLeague(primaryLeague);
            
        }
    }
    
    
    func getTeamsByLeague(league: League) {
        // todo: check coredata first
        
        
        
        parseClient.getTeamsByLeague(league) { result, error in
            // TODO: handle if error
            
            
            if let teamArray = result {
                self.teams.removeAll(keepCapacity: true)
                for team in teamArray {
                    var dict: [String:AnyObject] = [:]
                    
                    dict["teamName"] = ""
                    dict["teamColor"] = "127.0|127.0|127.0"
                    dict["gamesWon"] = 0
                    dict["gamesLost"] = 0
                    dict["gamesTied"] = nil
                    dict["leagueId"] = ""
                    dict["objectId"] = team.objectId!
                    dict["updatedAt"] = team.updatedAt!
                    
                    if let teamName = team["teamName"] as? String {
                        dict["teamName"] = teamName
                    }
                    if let gamesWon = team["gamesWon"] as? Int {
                        dict["gamesWon"] = gamesWon
                    }
                    if let gamesLost = team["gamesLost"] as? Int {
                        dict["gamesLost"] = gamesLost
                    }
                    if let gamesTied = team["gamesTied"] as? Int {
                        dict["gamesTied"] = gamesTied
                    }
                    if let headCoach = team["headCoach"] as? Int {
                        dict["headCoach"] = headCoach
                    }
                    if let leagueId = team["leagueId"] as? PFObject {
                        dict["leagueId"] = leagueId.objectId!
                    }
                    if let teamColor = team["teamColor"] as? String {
                        dict["teamColor"] = teamColor
                    }

                    // store the data we got from parse in core data so app can be
                    // used offline if user is not connected to the internet
                    
                    if let coredataTeam = self.coreDataContext.getTeamByObjectId(team.objectId!) {
                        self.teams.append(coredataTeam)
                        coredataTeam.updateObject(dict)
                        coredataTeam.league = league
                    } else {
                        let newTeam = Team(dictionary: dict, context: self.sharedContext)
                        newTeam.league = league
                        self.teams.append(newTeam)
                    }
                }
                // after all teams are created, reolad table view
                dispatch_async(dispatch_get_main_queue()) {
                    self.stackManager.saveContext()
                    self.teams.sortInPlace({$0.gamesWon > $1.gamesWon})
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "leagueTeamsCell"
        let team = self.teams[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TeamTableViewCell
        
        let colorParts = team.teamColor.characters.split{$0 == "|"}.map(String.init)
        let r: CGFloat = CGFloat((colorParts[0] as NSString).floatValue)
        let g: CGFloat = CGFloat((colorParts[1] as NSString).floatValue)
        let b: CGFloat = CGFloat((colorParts[2] as NSString).floatValue)
        
        cell.teamNameLabel.text = team.teamName
        cell.gamesWonLabel.text = "\(team.gamesWon)"
        cell.gamesLostLabel.text = "\(team.gamesLost)"
        cell.gamesTiedLabel.text = "\(team.gamesTied)"
        
        cell.backgroundColor = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)

        return cell

    }
}
