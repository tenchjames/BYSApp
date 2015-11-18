//
//  LeagueAdminViewController.swift
//  BysGameStats
//
//  Created by James Tench on 10/21/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse

class LeagueAdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var adminOptions = [String]()
    var userRoles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Helpers.showActivityIndicator(activityIndicator)
        tableView.hidden = true
        if let user = PFUser.currentUser() {
            
            let query = PFRole.query()
            
            query?.whereKey("users", equalTo: user)
            query?.findObjectsInBackgroundWithBlock() { results, error in
                if let roles = results {
                    for role in roles {
                        self.userRoles.append(role["name"] as! String)
                    }
                }
                
                if self.userRoles.contains("admin") {
                    self.adminOptions.append("Create New League")
                }
                if self.userRoles.contains("commissioner") {
                    self.adminOptions.append("Create New Team")
                    self.adminOptions.append("Create New Coach")
                    self.adminOptions.append("Create New Game")
                }
                Helpers.hideActivityIndicator(self.activityIndicator)
                self.tableView.reloadData()
                self.tableView.hidden = false
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adminOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "leagueAdminCell"
        let option = self.adminOptions[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = option
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let option = adminOptions[indexPath.row]
        if option == "Create New Team" {
            var controller : SelectLeagueViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("SelectLeagueViewController") as! SelectLeagueViewController
            controller.exitAction = "Team"
            self.navigationController?.pushViewController(controller, animated: true)
        } else if option == "Create New League" {
            var controller : CreateLeagueViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("CreateLeagueViewController") as! CreateLeagueViewController
            self.navigationController?.pushViewController(controller, animated: true)
        } else if option == "Create New Coach" {
            var controller : SelectLeagueViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("SelectLeagueViewController") as! SelectLeagueViewController
            controller.exitAction = "Coach"
            self.navigationController?.pushViewController(controller, animated: true)
        } else if option == "Create New Game" {
            var controller : SelectLeagueViewController
            controller = self.storyboard!.instantiateViewControllerWithIdentifier("SelectLeagueViewController") as! SelectLeagueViewController
            controller.exitAction = "Game"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

}
