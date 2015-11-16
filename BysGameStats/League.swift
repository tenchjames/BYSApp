//
//  League.swift
//  BysGameStats
//
//  Created by James Tench on 10/16/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData
import Parse
@objc(League)

class League : NSManagedObject {
    @NSManaged var objectId: String
    @NSManaged var year: NSNumber
    @NSManaged var updatedAt: NSDate
    @NSManaged var commissionerEmail: String
    @NSManaged var leagueType: String
    @NSManaged var ageGroup: String
    @NSManaged var leagueName : String
    @NSManaged var teams : [Team]
    
    
    let coreDataContext = CoreDataContext.sharedInstance
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var stackManager: CoreDataStackManager {
        return CoreDataStackManager.sharedInstance()
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // track in core data
        let entity = NSEntityDescription.entityForName("League", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // generate unique id for this pin
        objectId = dictionary["objectId"] as! String
        // set object properties with dictionary of values
        self.updateObject(dictionary)
    }
    
    func updateObject(dictionary: [String: AnyObject]) {
        // set object properties with dictionary of values
        
        if let year = dictionary["year"] as? Int {
            self.year = year
        }
        if let updatedAt = dictionary["updatedAt"] as? NSDate {
            self.updatedAt = updatedAt
        }
        if let commissionerEmail = dictionary["commissionerEmail"] as? String {
            self.commissionerEmail = commissionerEmail
        }
        if let leagueType = dictionary["leagueType"] as? String {
            self.leagueType = leagueType
        }
        if let ageGroup = dictionary["ageGroup"] as? String {
            self.ageGroup = ageGroup
        }
        if let leagueName = dictionary["leagueName"] as? String {
            self.leagueName = leagueName
        }
    }
    
}
