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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adminButton: AdminButton!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var leagueSelectButton: UIBarButtonItem!

    // todo add transparent image logos that can be used per team
    var primaryLeague: League?
    var teams: [Team] = [Team]()
    let parseClient = ParseClient.sharedInstance
    // variable to stop screen swapping look...just hide stuff until loaded first time
    // app is called
    var firstLoad = true
    
    let coreDataContext = CoreDataContext.sharedInstance
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }

    var tapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTripleTaps:")
        tapGestureRecognizer.numberOfTapsRequired = 3
        summaryView.addGestureRecognizer(tapGestureRecognizer)
        adminButton.enabled = false
        adminButton.hidden = true
        guard let _ = self.primaryLeague else {
            showLeagues(true)
            return
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if firstLoad {
            firstLoad = false
            tableView.hidden = true
            summaryView.hidden = true
        } else {
            tableView.hidden = false
            summaryView.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // if a primary league is selected, show the details
        // else prompt the user to pick their primary league from a list
        if let primaryLeague = self.primaryLeague {
            leagueNameLabel.text = primaryLeague.leagueName
            getTeamsByLeague(primaryLeague);
            // if the league changes, keep it in sync on the other tab for schedules
            let navController = self.tabBarController?.viewControllers![1] as! UINavigationController
            let scheduleTab = navController.topViewController as! LeagueScheduleViewController
            scheduleTab.primaryLeague = self.primaryLeague
        }
    }
    
    func handleTripleTaps(recognizer: UITapGestureRecognizer) {
        adminButton.enabled = !adminButton.enabled
        adminButton.hidden = !adminButton.hidden
    }
    
    func getTeamsByLeague(league: League) {
        if let teamArray = coreDataContext.getTeamsByLeague(league) {
            self.teams.removeAll(keepCapacity: true)
            for team in teamArray {
                self.teams.append(team)
            }
            self.teams.sortInPlace({$0.gamesWon > $1.gamesWon})
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "leagueTeamsCell"
        let team = self.teams[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! TeamTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.teamNameLabel.text = team.teamName
        cell.gamesWonLabel.text = "\(team.gamesWon)"
        cell.gamesLostLabel.text = "\(team.gamesLost)"
        cell.gamesTiedLabel.text = "\(team.gamesTied)"
        cell.teamImageView.backgroundColor = team.getColor()

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("TeamViewController") as! TeamViewController
        
        destinationViewController.team = teams[indexPath.row]
        destinationViewController.league = primaryLeague
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    @IBAction func showLeagues(isInitialLoad: Bool) {
        let leagueSelectionController = self.storyboard!.instantiateViewControllerWithIdentifier("LoadLeagueViewController") as! LoadLeagueViewController
        leagueSelectionController.isInitialLoad = isInitialLoad
        self.presentViewController(leagueSelectionController, animated: true, completion: nil)
        
    }
}
