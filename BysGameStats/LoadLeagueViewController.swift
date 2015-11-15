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
    //var isInitialLoad = true

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
        primaryLeague = league
        doneEditing()
    }
}
