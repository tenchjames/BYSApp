//
//  LeagueScheduleViewController.swift
//  BysGameStats
//
//  Created by James Tench on 11/1/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData
import UIKit

import Parse

class LeagueScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var games: [Game] = [Game]()
    var primaryLeague: League?
    let datePlayedFormatter = NSDateFormatter()
    
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
        datePlayedFormatter.dateFormat = "EEE MM/dd/yyyy"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let primaryLeague = self.primaryLeague {
            getGamesByLeague(primaryLeague)
        }
    }
    
    // MARK: - Tableview datasouce and delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeagueScheduleCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        cell.homeTeamLabel.text = games[indexPath.row].homeTeam?.teamName
        cell.awayTeamLabel.text = games[indexPath.row].awayTeam?.teamName
        cell.dateTimeLabel.text = datePlayedFormatter.stringFromDate(games[indexPath.row].currentlyScheduledDate)
        return cell
    }
    
    // the logic is that only a coach of one of the teams involved should be allowed to edit the game
    // scores. this checks that, and decides if the user can transition to the edit page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let game = games[indexPath.row]
        // all games should have a home team and away team
        guard let homeTeam = game.homeTeam else {
            return
        }
        guard let awayTeam = game.awayTeam else {
            return
        }
        
        var coachType: String?
        if let user = PFUser.currentUser() {
            guard let email = user.email else {
                return
            }
            guard let league = game.league else {
                return
            }
            guard let coaches = coreDataContext.getCoachByLeagueAndEmail(league, email: email) else {
                return
            }
            
            for coach in coaches {
                if let teamCoaching = coach.teamCoaching {
                    if teamCoaching == homeTeam {
                        coachType = "homeTeamCoach"
                    } else if teamCoaching == awayTeam {
                        coachType = "awayTeamCoach"
                    }
                    // if we found the coach, break the loop
                    if coachType != nil {
                        break
                    }
                }
            }
            // if the coach was not set, then return because this person was not found to be
            // a coach on either team
            guard let coachType = coachType else {
                return
            }
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EditGameViewController") as! EditGameViewController
            controller.game = game
            controller.coachType = coachType
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func getGamesByLeague(league: League) {
        if let gameArray = coreDataContext.getGamesByLeague(league) {
            self.games.removeAll(keepCapacity: true)
            for game in gameArray {
                self.games.append(game)
            }
            self.tableView.reloadData()
        }
    }

}
