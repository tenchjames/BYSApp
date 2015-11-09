//
//  ParseClient.swift
//  BysGameStats
//
//  Created by James Tench on 10/18/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import CoreData
import Parse

class ParseClient {
    static let sharedInstance = ParseClient()
    
    let coreDataContext = CoreDataContext.sharedInstance
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }

    func getUserLeagueInfo(user: PFUser, completionHandler: (result: PFObject?, error: NSError?) -> Void) {
        guard let leagueObject = user["primaryLeague"] as? PFObject else {
            completionHandler(result: nil, error: nil)
            return
        }
        
        guard let leagueId = leagueObject.objectId else {
            completionHandler(result: nil, error: nil)
            return
        }
        let leagueQuery = PFQuery(className: "League")
        // get the users league information
        leagueQuery.getObjectInBackgroundWithId(leagueId) { obj, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let obj = obj {
                    completionHandler(result: obj, error: nil)
                } else {
                    // TODO: NEED TO CREATE ERROR or handle none
                    completionHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    func getCoachesByLeague(league: League, completionHandler: (result: [PFObject]?, error: NSError?) -> Void) {
        let pointer = PFObject(className: "League")
        pointer.objectId = league.objectId
        
        let coachesQuery = PFQuery(className: "Coach")
        coachesQuery.whereKey("league", equalTo: pointer)
        coachesQuery.findObjectsInBackgroundWithBlock() { result, error in
            if let error = error {
                // TODO: code for errors
                print(error)
            } else {
                if let result = result {
                    completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    func getGamesByLeague(league: League, completionHandler: (result: [PFObject]?, error: NSError?) -> Void) {
        let leaguePointer = PFObject(className: "League")
        leaguePointer.objectId = league.objectId
        
        let leaguesGameQuery = PFQuery(className: "Game")
        leaguesGameQuery.whereKey("leaguePointer", equalTo: leaguePointer)
        leaguesGameQuery.findObjectsInBackgroundWithBlock() { result, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let result = result {
                    completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    func getTeamsByLeague(league: League, completionHandler: (result: [PFObject]?, error: NSError?) -> Void) {
        let pointer = PFObject(className: "League")
        pointer.objectId = league.objectId
        
        let teamsQuery = PFQuery(className: "Team")
        teamsQuery.whereKey("league", equalTo: pointer)
        teamsQuery.findObjectsInBackgroundWithBlock() { result, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let result = result {
                    completionHandler(result: result, error: nil)
                } else {
                    completionHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    func getLeagues(completionsHandler: (result: [PFObject]?, error: NSError?) -> Void) {
        let leaguesQuery = PFQuery(className: "League")
        leaguesQuery.orderByDescending("year")
        leaguesQuery.orderByAscending("leagueName")
        leaguesQuery.findObjectsInBackgroundWithBlock() { results, error in
            if let error = error {
                completionsHandler(result: nil, error: error)
            } else {
                if let leagues = results {
                    completionsHandler(result: leagues, error: nil)
                } else {
                    completionsHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    func getLeaguesByCommissionerEmail(email: String, completionHandler: (result: [PFObject]?, error: NSError?) -> Void) {
        let leaguesQuery = PFQuery(className: "League")
        leaguesQuery.whereKey("commissionerEmail", equalTo: email)
        leaguesQuery.findObjectsInBackgroundWithBlock() { results, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = results {
                    completionHandler(result: results, error: nil)
                } else {
                    completionHandler(result: nil, error: nil)
                }
            }
        }
    }
    
    // parse guarantees unique email addresses
//    func getUserByEmailAddress(email: String, completionHandler: (result: PFObject?, error: NSError?) -> Void) {
//        let userQuery = PFQuery(className: "_User")
//        let email = email.lowercaseString
//        userQuery.whereKey("email", equalTo: email)
//        userQuery.getFirstObjectInBackgroundWithBlock() { user, error in
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                if let user = user {
//                    completionHandler(result: user, error: nil)
//                } else {
//                    completionHandler(result: nil, error: nil)
//                }
//            }
//        }
//    }
    
    // mega call to get objects to load the league data on the users device
    func getAllLeagueObjectsByLeagueId(league: League, completionHandler: ([PFObject]?, NSError?) -> Void) {
        var parseObjects = [PFObject]()
        
        let leagueQuery = PFQuery(className: "League")
        leagueQuery.whereKey("objectId", equalTo: league.objectId)
        leagueQuery.getFirstObjectInBackgroundWithBlock() { results, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let league = results {
                    parseObjects.append(league)
                }
                
                // succes to here...get league teams
                self.getTeamsByLeague(league) { results, error in
                    if let error = error {
                        // error getting teams, send back any league info
                        completionHandler(parseObjects, error)
                    } else {
                        if let teams = results {
                            parseObjects += teams
                        }
                        // get game objects
                        self.getGamesByLeague(league) { results, error in
                            if let error = error {
                                completionHandler(parseObjects, error)
                            } else {
                                if let games = results {
                                    parseObjects += games
                                }
                                // get coach objects
                                self.getCoachesByLeague(league) { results, error in
                                    if let error = error {
                                        completionHandler(parseObjects, error)
                                    } else {
                                        if let coaches = results {
                                            parseObjects += coaches
                                        }
                                        completionHandler(parseObjects, nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func leagueFromPFObject(obj: PFObject) -> League? {
        var newLeague: League?
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let year = obj["year"] as? Int {
            dict["year"] = year
        }
        if let leagueType = obj["leagueType"] as? String {
            dict["leagueType"] = leagueType
        }
        if let ageGroup = obj["ageGroup"] as? String {
            dict["ageGroup"] = ageGroup
        }
        if let leagueName = obj["leagueName"] as? String {
            dict["leagueName"] = leagueName
        }
        if let commissionerEmail = obj["commissionerEmail"] as? String {
            dict["commissionerEmail"] = commissionerEmail
        }
        
        // store the data we got from parse in core data so app can be
        // used offline if user is not connected to the internet
        
        if let coredataLeague = self.coreDataContext.getLeagueIdByObjectId(obj.objectId!){
            newLeague = coredataLeague
            dispatch_async(dispatch_get_main_queue()) {
                coredataLeague.updateObject(dict)
                self.stackManager.saveContext()
            }
        } else {
            newLeague = League(dictionary: dict, context: self.sharedContext)
            dispatch_async(dispatch_get_main_queue()) {
                self.stackManager.saveContext()
            }
        }
        return newLeague
    }
    
//    func coachFromPFObject(obj: PFObject) -> Coach? {
//        var newCoach: Coach?
//        var dict = [String : AnyObject]()
//        // all PFObjects should have an object id
//        guard let objectId = obj.objectId else {
//            return nil
//        }
//        dict["objectId"] = objectId
//        
//        if let updatedAt = obj.updatedAt {
//            dict["updatedAt"] = updatedAt
//        }
//        if let coachName = obj["coachName"] as? String {
//            dict["coachName"] = coachName
//        }
//        if let coachEmail = obj["coachEmail"] as? String {
//            dict["coachEmail"] = coachEmail
//        }
//        if let cellPhoneNmber = obj["cellPhoneNumber"] as? String {
//            dict["cellPhoneNumber"] = cellPhoneNmber
//        }
//        if let isHeadCoach = obj["isHeadCoach"] as? Int {
//            dict["isHeadCoach"] = isHeadCoach
//        }
//        
//        if let coach = self.coreDataContext.getCoachByObjectId(obj.objectId!){
//            newCoach = coach
//            dispatch_async(dispatch_get_main_queue()) {
//                coach.updateObject(dict)
//                self.stackManager.saveContext()
//            }
//        } else {
//            newCoach = Coach(dictionary: dict, context: self.sharedContext)
//            dispatch_async(dispatch_get_main_queue()) {
//                self.stackManager.saveContext()
//            }
//        }
//        return newCoach
//    }
    
    func teamFromPFObject(obj: PFObject) -> Team? {
        var newTeam: Team?
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let teamName = obj["teamName"] as? String {
            dict["teamName"] = teamName
        }
        if let gamesWon = obj["gamesWon"] as? Int {
            dict["gamesWon"] = gamesWon
        }
        if let gamesLost = obj["gamesLost"] as? Int {
            dict["gamesLost"] = gamesLost
        }
        if let gamesTied = obj["gamesTied"] as? Int {
            dict["gamesTied"] = gamesTied
        }
        if let teamColor = obj["teamColor"] as? String {
            dict["teamColor"] = teamColor
        }
        
        if let objectId = obj.objectId,
               team = self.coreDataContext.getTeamByObjectId(objectId)
        {
            newTeam = team
            dispatch_async(dispatch_get_main_queue()) {
                team.updateObject(dict)
                self.stackManager.saveContext()
            }
        } else {
            newTeam = Team(dictionary: dict, context: self.sharedContext)
            dispatch_async(dispatch_get_main_queue()) {
                self.stackManager.saveContext()
            }
        }
        return newTeam
    }
    
    
    func leagueAttributes(obj: PFObject) -> [String: AnyObject]? {
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let year = obj["year"] as? Int {
            dict["year"] = year
        }
        if let leagueType = obj["leagueType"] as? String {
            dict["leagueType"] = leagueType
        }
        if let ageGroup = obj["ageGroup"] as? String {
            dict["ageGroup"] = ageGroup
        }
        if let leagueName = obj["leagueName"] as? String {
            dict["leagueName"] = leagueName
        }
        if let commissionerEmail = obj["commissionerEmail"] as? String {
            dict["commissionerEmail"] = commissionerEmail
        }
        return dict
    }
    
    
    func teamAttributes(obj: PFObject) -> [String: AnyObject]? {
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let teamName = obj["teamName"] as? String {
            dict["teamName"] = teamName
        }
        if let teamColor = obj["teamColor"] as? String {
            dict["teamColor"] = teamColor
        }
        return dict
    }
    
    func coachAttributes(obj: PFObject) -> [String: AnyObject]? {
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let coachName = obj["coachName"] as? String {
            dict["coachName"] = coachName
        }
        if let coachEmail = obj["coachEmail"] as? String {
            dict["coachEmail"] = coachEmail
        }
        if let cellPhoneNmber = obj["cellPhoneNumber"] as? String {
            dict["cellPhoneNumber"] = cellPhoneNmber
        }
        if let isHeadCoach = obj["isHeadCoach"] as? Int {
            dict["isHeadCoach"] = isHeadCoach
        }

        return dict
    }
    
    func gameAttributes(obj: PFObject) -> [String: AnyObject]? {
        var dict = [String : AnyObject]()
        // all PFObjects should have an object id
        guard let objectId = obj.objectId else {
            return nil
        }
        dict["objectId"] = objectId
        
        if let updatedAt = obj.updatedAt {
            dict["updatedAt"] = updatedAt
        }
        if let originalSchedule = obj["originalScheduledDate"] as? NSDate {
            dict["originalScheduledDate"] = originalSchedule
        }
        if let currentlyScheduled = obj["currentlyScheduledDate"] as? NSDate {
            dict["currentlyScheduledDate"] = currentlyScheduled
        }
        if let homeTeamScore = obj["homeTeamScore"] as? Int {
            dict["homeTeamScore"] = homeTeamScore
        }
        if let awayTeamScore = obj["awayTeamScore"] as? Int {
            dict["awayTeamScore"] = awayTeamScore
        }
        if let status = obj["status"] as? String {
            dict["status"] = status
        }
        return dict
    }
}
