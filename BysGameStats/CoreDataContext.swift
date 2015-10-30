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
}
