//
//  LoadLeagueViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/30/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class LoadLeagueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var leagues = [League]()
    let reuseIdentifier = "LeagueCell"
    
    let parseClient = ParseClient.sharedInstance
    let coreDataContext = CoreDataContext.sharedInstance
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
    
    let defaultMinutesBeforeReload = 60.0
    
    var primaryLeague: League?
    var isInitialLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        parseClient.getLeagues() { result, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error getting leagues", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                if let leagues = result {
                    for league in leagues {
                        if let newLeague = self.parseClient.leagueFromPFObject(league) {
                            self.leagues.append(newLeague)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }

        if isInitialLoad {
            tableView.hidden = true
            toolBar.hidden = true
            isInitialLoad = false
            loadingView.hidden = false
            loadingView.alpha = 1.0
            activityIndicator.startAnimating()
            checkLeaguePreferenceAndLastUpdate()
        } else {
            tableView.hidden = false
            toolBar.hidden = false
            loadingView.hidden = true
            loadingView.alpha = 0.0
        }
    }
    
    func checkLeaguePreferenceAndLastUpdate() {
        if let leaguePreference = getLeaguePreference() {
            if let savedLeagueId = leaguePreference["primaryLeague"] as? String {
                // get the league out of core data
                if let savedLeague = CoreDataContext.sharedInstance.getLeagueIdByObjectId(savedLeagueId) {
                    primaryLeague = savedLeague
                }
                // if the league has not been loaded in x amount of time (need to decide / test)
                // then call parse and reload the data
                // else, the data has been loaded for the app and can be used based off coredata
                if let lastUpdateTime = leaguePreference["lastUpdateTime"] as? NSDate {
                    let timeDifference = NSDate().timeIntervalSinceDate(lastUpdateTime)
                    let minutes = timeDifference / 60
                    if minutes < defaultMinutesBeforeReload {
                        // we can just jump to the initial view because of timing set
                        dispatch_async(dispatch_get_main_queue()) {
                            self.doneEditing()
                        }
                        return
                    }
                }
            }
        }
        
        // if we got to this point, the new view did not load for 1 of 2 reasons
        // either the user does not have a default preference saved, or the preference
        // they have saved is outdated.
        // if it is outdated, call parse to update, then tranistion
        // if it is not selected yet, continue and let view show options
        // to make a choice for a default
        guard let selectedLeague = primaryLeague else {
            dispatch_async(dispatch_get_main_queue()) {
                self.doneEditing()
            }
            return
        }

        getLeague(selectedLeague)
    }
    
    func getLeague(league: League) {
        // they have a choice, but it is old...query parse
        queryParseToLoadData(league) { success, error in
            if success {
                self.saveLeaguePreference()
                dispatch_async(dispatch_get_main_queue()) {
                    self.doneEditing()
                }
            }
            // otherwise just let function return and display the current selection page
            // todo: if error report it
        }
    }
    
    func queryParseToLoadData(league: League, completionHandler: (success: Bool, error: NSError?)->Void) {
        parseClient.getAllLeagueObjectsByLeagueId(league) { results, error in
            if let error = error {
                // check if any results...if some some other error happened mid request
                print(error)
                if let _ = results {
                    print("some objects, but error")
                    // TODO: DO SOMETHING IN THIS CASE
                }
                completionHandler(success: false, error: error)
            } else {
                if let parseObjects = results {
                    self.saveParseToCoreData(parseObjects, completionHandler: completionHandler)
                }
            }
        }
    }
    
    func saveParseToCoreData(parseObjects: [PFObject], completionHandler: (success: Bool, error: NSError?)->Void) {
        // objects were retrieved in hierarchy order
        // league, then teams, then games and coaches
        // keep track of league and teams so we don't keep reloading
        // them in coredata
        var league: League?
        var teams = [Team]()
        var games = [Game]()

        for parse in parseObjects {
            guard let _ = parse.objectId else {
                continue;
            }
            
            let parseClass = parse.parseClassName
            switch parseClass {
            case "League":
                guard let dict = parseClient.leagueAttributes(parse) else {
                    continue
                }
                league = coreDataContext.leagueFromDictionary(dict)
            case "Team":
                guard var dict = parseClient.teamAttributes(parse) else {
                    continue
                }
                if let setLeague = league {
                    dict["league"] = setLeague
                }
                dict["gamesWon"] = 0
                dict["gamesLost"] = 0
                dict["gamesTied"] = 0

                if let newTeam = coreDataContext.teamFromDictionary(dict) {
                    teams.append(newTeam)
                }
                
            case "Game":
                guard var dict = parseClient.gameAttributes(parse) else {
                    continue
                }
                if let setLeague = league {
                    dict["league"] = setLeague
                }
                if let awayTeamPointer = parse["awayTeamPointer"].objectId {
                    for team in teams {
                        if team.objectId == awayTeamPointer {
                            dict["awayTeam"] = team
                            break
                        }
                    }
                }
                if let homeTeamPointer = parse["homeTeamPointer"].objectId {
                    for team in teams {
                        if team.objectId == homeTeamPointer {
                            dict["homeTeam"] = team
                            break
                        }
                    }
                }
                if let newGame = coreDataContext.gameFromDictionary(dict) {
                    games.append(newGame)
                }
            case "Coach":
                guard var dict = parseClient.coachAttributes(parse) else {
                    continue
                }
                if let setLeague = league {
                    dict["league"] = setLeague
                }
                if let teamCoaching = parse["teamCoaching"].objectId {
                    for team in teams {
                        if team.objectId == teamCoaching {
                            dict["teamCoaching"] = team
                            break
                        }
                    }
                }
                let _ = coreDataContext.coachFromDictionary(dict)
            default:
                continue;
            }
        }
        
        // after all the objects have been loaded, loop over the games
        // to set team wins and losses
        dispatch_async(dispatch_get_main_queue()) {
            for game in games {
                if game.status == "complete" || game.status == "confirmed" {
                    if game.homeTeamScore > game.awayTeamScore {
                        if let homeTeam = game.homeTeam {
                            homeTeam.gamesWon += 1
                        }
                        if let awayTeam = game.awayTeam {
                            awayTeam.gamesLost += 1
                        }
                    } else if game.awayTeamScore > game.homeTeamScore {
                        if let homeTeam = game.homeTeam {
                            homeTeam.gamesLost += 1
                        }
                        if let awayTeam = game.awayTeam {
                            awayTeam.gamesWon += 1
                        }
                    } else {
                        if let homeTeam = game.homeTeam {
                            homeTeam.gamesTied += 1
                        }
                        if let awayTeam = game.awayTeam {
                            awayTeam.gamesTied += 1
                        }
                    }
                }
            }
            self.saveLeaguePreference()
            self.stackManager.saveContext()
            completionHandler(success: true, error: nil)
        }
    }
    
    // TODO: maybe present this view controller modally and do this differen
    func doneEditing() {
        let navController = self.presentingViewController as! UINavigationController
        let tabController = navController.viewControllers[navController.viewControllers.count - 1] as! UITabBarController
        let leaguesController = tabController.viewControllers?.first as! LeagueViewController
        leaguesController.primaryLeague = self.primaryLeague
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func donePressed(sender: AnyObject) {
        doneEditing()
    }
    
    func saveLeaguePreference() {
        var dictionary = [String: AnyObject]()
        if let selectedLeague = primaryLeague {
            dictionary["primaryLeague"] = selectedLeague.objectId
        } else {
            dictionary["primaryLeague"] = nil
        }
        dictionary["lastUpdateTime"] = NSDate()
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func getLeaguePreference() -> [String: AnyObject]? {
        if let leaguePreferences = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            return leaguePreferences
        }
        return nil
    }

    // MARK: Tableview datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = leagues[indexPath.row].leagueName
        cell.detailTextLabel?.text = "\(leagues[indexPath.row].year)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let league = leagues[indexPath.row]
        self.primaryLeague = league
        self.queryParseToLoadData(league) { result, error in
            if let _ = error {
                let ac = UIAlertController(title: "Error", message: "Sorry there was an error saving the team", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            } else {
                self.saveLeaguePreference()
                self.doneEditing()
            }
        }
    }
}
