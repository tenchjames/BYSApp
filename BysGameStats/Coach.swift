//
//  Coach.swift
//  BysGameStats
//
//  Created by James Tench on 10/22/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData
@objc(Coach)


class Coach : NSManagedObject {
    @NSManaged var objectId: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var coachName: String
    @NSManaged var coachEmail: String
    @NSManaged var cellPhoneNumber: String
    @NSManaged var isHeadCoach: NSNumber
    @NSManaged var teamCoaching: Team?
    @NSManaged var league: League?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // track in core data
        let entity = NSEntityDescription.entityForName("Coach", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // generate unique id for this pin
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        }
        
        self.updateObject(dictionary)
    }
    
    func updateObject(dictionary: [String: AnyObject]) {
        if let coachName = dictionary["coachName"] as? String {
            self.coachName = coachName
        }
        
        if let updatedAt = dictionary["updatedAt"] as? NSDate {
            self.updatedAt = updatedAt
        }
        
        if let coachEmail = dictionary["coachEmail"] as? String {
            self.coachEmail = coachEmail
        }
        
        if let cellPhoneNumber = dictionary["cellPhoneNumber"] as? String {
            self.cellPhoneNumber = cellPhoneNumber
        }
        
        if let isHeadCoach = dictionary["isHeadCoach"] as? NSNumber {
            self.isHeadCoach = isHeadCoach
        }
        
        if let teamCoaching = dictionary["teamCoaching"] as? Team {
            self.teamCoaching = teamCoaching
        }
        
        if let league = dictionary["league"] as? League {
            self.league = league
        }
    }
    
}
