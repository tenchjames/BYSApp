//
//  TeamViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/28/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import CoreData
import Parse

class TeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamColorView: UIView!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    // dependency - team and league must be passed in
    var team: Team?
    var league: League?
    var games = [Game]()
    var gamesWon = 0
    var gamesLost = 0
    var gamesTied = 0
    
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
        if let team = self.team {
            getGamesByTeam(team);
            teamNameLabel.text = team.teamName;
            teamColorView.backgroundColor = team.getColor()
        }
    }
    
    func getGamesByTeam(team: Team) {
        if let gamesArray = coreDataContext.getGamesByTeam(team) {
            self.games.removeAll(keepCapacity: true)
            for game in gamesArray {
                if game.status == "complete" || game.status == "confirmed" {
                    var winner: Team? = nil
                    if game.homeTeamScore > game.awayTeamScore {
                        winner = game.homeTeam
                    } else if game.awayTeamScore > game.homeTeamScore {
                        winner = game.awayTeam
                    }
                    
                    if let winningTeam = winner {
                        if let thisTeam = self.team {
                            if winningTeam == thisTeam {
                                self.gamesWon += 1
                            } else {
                                self.gamesLost += 1
                            }
                        }
                    } else {
                        gamesTied += 1
                    }
                }
                
                self.games.append(game)
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: tableview datasource and delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return games.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gameCell", forIndexPath: indexPath) as! GameTableViewCell
        configureCellAtIndexPath(cell, indexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let game = games[section]
        return datePlayedFormatter.stringFromDate(game.currentlyScheduledDate)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let game = games[indexPath.section]
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
    
    
    func configureCellAtIndexPath(cell: GameTableViewCell, indexPath: NSIndexPath) {
        let game = games[indexPath.section]
        var homeTeamText: String
        var awayTeamText: String
        if let hometeam = game.homeTeam {
            homeTeamText = hometeam.teamName
        } else {
            homeTeamText = "Invalid Team Name"
        }
        
        if let awayTeam = game.awayTeam {
            awayTeamText = awayTeam.teamName
        } else {
            awayTeamText = "Invalid Team Name"
        }
        
        cell.homeTeamLabel.text = homeTeamText
        cell.awayTeamLabel.text = awayTeamText
        
        if game.status == "complete" || game.status == "confirmed" {
            let greenColor = UIColor(red: 15.0 / 255.0, green: 176 / 255.0, blue: 22.0 / 255.0, alpha: 1.0)
            let redColor = UIColor(red: 176.0 / 255.0, green: 12.0 / 255.0, blue: 4.0 / 255.0, alpha: 1.0)
            let grayColor = UIColor(red: 88.0 / 255.0, green: 99.0 / 255.0, blue: 118.0 / 255, alpha: 1.0)
            if game.homeTeamScore > game.awayTeamScore {
                cell.homeTeamScore.textColor = greenColor
                cell.awayTeamScore.textColor = redColor
            } else if game.awayTeamScore > game.homeTeamScore {
                cell.homeTeamScore.textColor = redColor
                cell.awayTeamScore.textColor = greenColor
            } else {
                cell.homeTeamScore.textColor = grayColor
                cell.awayTeamScore.textColor = grayColor
            }
            cell.homeTeamScore.text = "\(game.homeTeamScore)"
            cell.awayTeamScore.text = "\(game.awayTeamScore)"

        } else {
            cell.homeTeamScore.text = "- - -"
            cell.awayTeamScore.text = "- - -"
        }
    }
}






























