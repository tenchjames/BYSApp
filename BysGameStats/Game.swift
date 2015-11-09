//
//  Game.swift
//  BysGameStats
//
//  Created by James Tench on 10/28/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData
@objc(Game)

class Game : NSManagedObject {
    @NSManaged var objectId: String
    @NSManaged var originalScheduledDate: NSDate
    @NSManaged var currentlyScheduledDate: NSDate
    @NSManaged var homeTeamScore: Int
    @NSManaged var awayTeamScore: Int
    @NSManaged var status: String
    @NSManaged var homeTeam: Team?
    @NSManaged var awayTeam: Team?
    @NSManaged var league: League?

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dict: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if let objectId = dict["objectId"] as? String {
            self.objectId = objectId
        }
        self.updateObject(dict)
    }
    
    func updateObject(dict: [String : AnyObject]) {
        if let originalScheduledDate = dict["originalScheduledDate"] as? NSDate {
            self.originalScheduledDate = originalScheduledDate
        }
        
        if let currentlyScheduledDate = dict["currentlyScheduledDate"] as? NSDate {
            self.currentlyScheduledDate = currentlyScheduledDate
        }
        
        if let homeTeamScore = dict["homeTeamScore"] as? Int {
            self.homeTeamScore = homeTeamScore
        }
        
        if let awayTeamScore = dict["awayTeamScore"] as? Int {
            self.awayTeamScore = awayTeamScore
        }
        
        if let status = dict["status"] as? String {
            self.status = status
        }
        
        if let homeTeam = dict["homeTeam"] as? Team {
            self.homeTeam = homeTeam
        }
        
        if let awayTeam = dict["awayTeam"] as? Team {
            self.awayTeam = awayTeam
        }
        
        if let league = dict["league"] as? League {
            self.league = league
        }
        
    }
    
}
