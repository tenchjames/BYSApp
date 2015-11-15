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
    @IBOutlet weak var weatherSummary: UILabel!

    // todo add transparent image logos that can be used per team
    var primaryLeague: League?
    var teams: [Team] = [Team]()
    let parseClient = ParseClient.sharedInstance
    
    // brunswick location - future can allow for other locations
    let coordinate: (lat: Double, long: Double) = (41.2442,-81.8283)
    
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

    var tapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "logOut")
        self.parentViewController?.navigationItem.leftBarButtonItem = logoutButton
        let leaguesButton = UIBarButtonItem(title: "Leagues", style: .Plain, target: self, action: "showLeagues")
        self.parentViewController?.navigationItem.rightBarButtonItem = leaguesButton

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTripleTaps:")
        tapGestureRecognizer.numberOfTapsRequired = 3
        summaryView.addGestureRecognizer(tapGestureRecognizer)
        adminButton.enabled = false
        adminButton.hidden = true
        let forecast = ForecastClient()
        forecast.getForecast(coordinate.lat, long: coordinate.long) { weather in
            if let currentWeather = weather {
                if let summary = currentWeather.summary,
                    precip = currentWeather.precipProbability {
                       self.weatherSummary.text = "\(summary) : Rain % \(precip)"
                }
            } else {
                self.weatherSummary.hidden = true
            }
            // if we don't have weather data do nothing silently don't show field
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // if a primary league is selected, show the details
        // else prompt the user to pick their primary league from a list
        if let primaryLeague = self.primaryLeague {
            var coreDataNeedsRefreshed = false
            if let leaguePreference = getLeaguePreference() {
                // if the league has not been loaded in x amount of time (need to decide / test)
                // then call parse and reload the data
                // else, the data has been loaded for the app and can be used based off coredata
                if let lastUpdateTime = leaguePreference["lastUpdateTime"] as? NSDate {
                    let timeDifference = NSDate().timeIntervalSinceDate(lastUpdateTime)
                    let minutes = timeDifference / 60
                    if minutes > defaultMinutesBeforeReload {
                        coreDataNeedsRefreshed = true
                    }
                }
            } else {
                coreDataNeedsRefreshed = true
            }
            
            if coreDataNeedsRefreshed {
                queryParseToLoadData(primaryLeague) { success, error in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.getTeamsByLeague(primaryLeague)
                            self.saveLeaguePreference()
                        }
                    }
                    // if no update??? error to user?
                }
            }

            leagueNameLabel.text = primaryLeague.leagueName
            getTeamsByLeague(primaryLeague);
            // if the league changes, keep it in sync on the other tab for schedules
            let scheduleTab = self.tabBarController?.viewControllers![1] as! LeagueScheduleViewController
            scheduleTab.primaryLeague = self.primaryLeague
        } else {
            showLeagues()
        }
    }
    
    func logOut() {
        PFUser.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
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
        cell.teamLogoView.fillColor = team.getColor()

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destinationViewController = storyboard?.instantiateViewControllerWithIdentifier("TeamViewController") as! TeamViewController
        destinationViewController.team = teams[indexPath.row]
        destinationViewController.league = primaryLeague
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    @IBAction func showLeagues() {
        let leagueSelectionController = self.storyboard!.instantiateViewControllerWithIdentifier("LoadLeagueViewController") as! LoadLeagueViewController
        self.tabBarController?.presentViewController(leagueSelectionController, animated: true, completion: nil)
    }
    
    func getLeaguePreference() -> [String: AnyObject]? {
        if let leaguePreferences = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            return leaguePreferences
        }
        return nil
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
            self.stackManager.saveContext()
            completionHandler(success: true, error: nil)
        }
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
    
}
