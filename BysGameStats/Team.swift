//
//  Team.swift
//  BysGameStats
//
//  Created by James Tench on 10/18/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData

@objc(Team)

class Team: NSManagedObject {
    @NSManaged var objectId: String
    @NSManaged var teamName: String
    @NSManaged var updatedAt: NSDate
    @NSManaged var gamesWon: Int
    @NSManaged var gamesLost: Int
    @NSManaged var gamesTied: Int
    @NSManaged var teamColor: String
    @NSManaged var league: League?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        // track in core data
        let entity = NSEntityDescription.entityForName("Team", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // generate unique id via parse
        if let objectId = dictionary["objectId"] as? String {
            self.objectId = objectId
        }
        self.updateObject(dictionary)
    }
    
    func updateObject(dictionary: [String: AnyObject]) {
        // set object properties with dictionary of values
        if let updatedAt = dictionary["updatedAt"] as? NSDate {
            self.updatedAt = updatedAt
        }
        
        if let teamName = dictionary["teamName"] as? String {
            self.teamName = teamName
        }
        
        if let gamesWon = dictionary["gamesWon"] as? Int {
            self.gamesWon = gamesWon
        }
        
        if let gamesLost = dictionary["gamesLost"] as? Int {
            self.gamesLost = gamesLost
        }
        
        if let gamesTied = dictionary["gamesTield"] as? Int {
            self.gamesTied = gamesTied
        }
        
        if let teamColor = dictionary["teamColor"] as? String {
            self.teamColor = teamColor
        }
    }
    
}
