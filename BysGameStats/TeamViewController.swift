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

class TeamViewController: UIViewController {
    var team: Team?
    var games = [Game]()
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
        if let team = self.team {
            getGamesByTeam(team);
        }

        // Do any additional setup after loading the view.
    }
    
    func getGamesByTeam(team: Team) {
        // todo check coredata first
        
        parseClient.getGamesByTeam(team) { result, error in
            if let error = error {
                // TODO: better error handling when error
                print(error)
            } else {
                if let gameArray = result {
                    // if we called parse, the update coredata
                    self.games.removeAll(keepCapacity: true)
                    for game in gameArray {
                        // at this point in the app flow teams
                        // should be in core data, however
                        // TODO: code back up plan to go to parse if the are not
                        
                        var dict: [String : AnyObject] = [:]
                        // set default values as dictionary cannot take nils
//                        @NSManaged var objectId: String
//                        @NSManaged var originalScheduledDate: NSDate
//                        @NSManaged var currentlyScheduledDate: NSDate
//                        @NSManaged var homeTeamScore: Int
//                        @NSManaged var awayTeamScore: Int
//                        @NSManaged var homeTeam: Team?
//                        @NSManaged var awayTeam: Team?
//                        @NSManaged var league: League?
                        dict["objectId"] = ""
                        dict["originalScheduledDate"] = ""
                        dict["currentlyScheduledDate"] = ""
                        dict["homeTeamScore"] = 0
                        dict["awayTeamScore"] = 0
                        
                        
                        
                    }
                } else {
                    // TODO: handle no results returned
                    print("no results returned")
                }
            }
        }
    }


}






























