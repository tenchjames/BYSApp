//
//  SelectTeamViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/25/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse

class SelectTeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var selectedLeague : League?
    var teams = [Team]()
    var exitAction : String?
    let parseClient = ParseClient.sharedInstance
    let reuseIdentifier = "TeamSelectCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedLeague = self.selectedLeague {
            parseClient.getTeamsByLeague(selectedLeague) { result, error in
                // TODO: ERROR HANDLING
                if let newteams = result {
                    self.teams.removeAll(keepCapacity: true)
                    for team in newteams {
                        if let newTeam = self.parseClient.teamFromPFObject(team) {
                            self.teams.append(newTeam)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = teams[indexPath.row].teamName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = exitAction else {
            return
        }
        guard let league = selectedLeague else {
            return
        }
        
        switch action {
        case "Coach":
            var controller : CreateCoachViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("CreateCoachViewController") as! CreateCoachViewController
            controller.selectedLeague = league
            controller.selectedTeam = teams[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        case "GameReturnHomeTeam":
            let priorControllerIndex = self.navigationController!.viewControllers.count - 2
            let controller = self.navigationController?.viewControllers[priorControllerIndex] as! CreateGameViewController
            controller.homeTeam = teams[indexPath.row]
            self.navigationController?.popViewControllerAnimated(true)
        case "GameReturnAwayTeam":
            let priorControllerIndex = self.navigationController!.viewControllers.count - 2
            let controller = self.navigationController?.viewControllers[priorControllerIndex] as! CreateGameViewController
            controller.awayTeam = teams[indexPath.row]
            self.navigationController?.popViewControllerAnimated(true)
        default:
            return
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a Team"
    }

}
