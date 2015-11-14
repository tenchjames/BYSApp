//
//  CoreDataContext.swift
//  BysGameStats
//
//  Created by James Tench on 10/18/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData

// class for querying against the coredata

class CoreDataContext {
    static let sharedInstance = CoreDataContext()

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    
    func getLeagueIdByObjectId(objectId: String) -> League? {
        let fetchRequest = NSFetchRequest(entityName: "League")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        var results: [League]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [League]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results?.first {
            return result
        }
        return nil
    }
    
    func getTeamsByLeague(league: League, limit: Int? = nil) -> [Team]? {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        fetchRequest.predicate = NSPredicate(format: "league == %@", league)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "teamName", ascending: false)]
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        var results: [Team]?

        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Team]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results {
            return result
        }
        return nil
    }
    
    func getTeamByObjectId(objectId: String) -> Team? {
        let fetchRequest = NSFetchRequest(entityName: "Team")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        var results: [Team]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Team]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results?.first {
            return result
        }
        return nil
    }
    
    func getCoachesByLeagueId(objectId: String, limit: Int? = nil) -> [Coach]? {
        let fetchRequest = NSFetchRequest(entityName: "Coach")
        fetchRequest.predicate = NSPredicate(format: "league == %@", objectId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "coachName", ascending: true)]
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }
        var results: [Coach]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Coach]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results {
            return result
        }
        return nil
    }
    
    func getCoachByObjectId(objectId: String) -> Coach? {
        let fetchRequest = NSFetchRequest(entityName: "Coach")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: false)]
        fetchRequest.fetchLimit = 1

        var results: [Coach]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Coach]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }

        if let result = results?.first {
            return result
        }
        return nil
    }
    
    func getCoachByLeagueAndEmail(league: League, email: String) -> [Coach]? {
        let fetchRequest = NSFetchRequest(entityName: "Coach")
        fetchRequest.predicate = NSPredicate(format: "league == %@ and coachEmail == %@", league, email)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "coachEmail", ascending: true)]
        
        var results: [Coach]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Coach]
        } catch _ {
            results  = nil
        }
        
        if let result = results {
            return result
        }
        return nil
    }
    
    func getGamesByTeam(team: Team, limit: Int? = nil) -> [Game]? {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "homeTeam == %@ or awayTeam == %@", team, team)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currentlyScheduledDate", ascending: true)]
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        var results: [Game]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Game]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results {
            return result
        }
        return nil
    }
    
    func getGamesByLeague(league: League, limit: Int? = nil) -> [Game]? {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "league == %@", league)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currentlyScheduledDate", ascending: true)]
        if let fetchLimit = limit {
            fetchRequest.fetchLimit = fetchLimit
        }

        var results: [Game]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Game]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results {
            return result
        }
        return nil
    }
    
    func getGameByObjectId(objectId: String) -> Game? {
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "objectId == %@", objectId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: true)]
        fetchRequest.fetchLimit = 1
        
        var results: [Game]?
        
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest) as? [Game]
        } catch _ {
            // if we have error, set result should be nil
            results = nil
        }
        
        if let result = results?.first {
            return result
        }
        return nil
    }
    
    // MARK: methods for sync objects to coredata
    
    // methods for keeping coredata in sync and checking if objects already exist
    func leagueFromDictionary(dict: [String:AnyObject]) -> League? {
        var newLeague: League?
        guard let objectId = dict["objectId"] as? String else {
            return nil
        }
        if let league = self.getLeagueIdByObjectId(objectId)
        {
            newLeague = league
            league.updateObject(dict)
        } else {
            newLeague = League(dictionary: dict, context: self.sharedContext)
        }
        return newLeague
    }
    
    func teamFromDictionary(dict: [String:AnyObject]) -> Team? {
        var newTeam: Team?
        guard let objectId = dict["objectId"] as? String else {
            return nil
        }
        if let team = self.getTeamByObjectId(objectId)
        {
            dispatch_async(dispatch_get_main_queue()) {
                team.updateObject(dict)
            }
            newTeam = team
            
        } else {
            newTeam = Team(dictionary: dict, context: self.sharedContext)
        }
        return newTeam
    }
    
    func coachFromDictionary(dict: [String:AnyObject]) -> Coach? {
        var newCoach: Coach?
        guard let objectId = dict["objectId"] as? String else {
            return nil
        }
        if let coach = self.getCoachByObjectId(objectId)
        {
            newCoach = coach
            coach.updateObject(dict)
        } else {
            
            newCoach = Coach(dictionary: dict, context: self.sharedContext)
        }
        return newCoach
    }
    
    func gameFromDictionary(dict: [String:AnyObject]) -> Game? {
        var newGame: Game?
        guard let objectId = dict["objectId"] as? String else {
            return nil
        }
        if let game = self.getGameByObjectId(objectId)
        {
            newGame = game
            game.updateObject(dict)
        } else {
            newGame = Game(dict: dict, context: self.sharedContext)
        }
        return newGame
    }
}
