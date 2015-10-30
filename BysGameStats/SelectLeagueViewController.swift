//
//  SelectLeagueViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/25/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse

class SelectLeagueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var leagues = [League]()
    let reuseIdentifier = "SelectAdminCell"
    let parseClient = ParseClient.sharedInstance
    var exitAction : String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = PFUser.currentUser() {
            if let email = user.email {
                parseClient.getLeaguesByCommissionerEmail(email) { result, error in
                    // TODO: erro handling
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "League Selection"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = leagues[indexPath.row].leagueName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let action = exitAction else {
            return
        }
        
        switch action {
        case "Team":
            var controller : CreateTeamViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("CreateTeamViewController") as! CreateTeamViewController
            controller.selectedLeague = leagues[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        case "Coach":
            var controller : SelectTeamViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("SelectTeamViewController") as! SelectTeamViewController
            controller.selectedLeague = leagues[indexPath.row]
            controller.exitAction = "Coach"
            self.navigationController?.pushViewController(controller, animated: true)
        case "Game":
            var controller : CreateGameViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("CreateGameViewController") as! CreateGameViewController
            controller.selectedLeague = leagues[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            return
        }
    }
}
