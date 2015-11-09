//
//  Team.swift
//  BysGameStats
//
//  Created by James Tench on 10/18/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import CoreData
import UIKit

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
        
        if let gamesTied = dictionary["gamesTied"] as? Int {
            self.gamesTied = gamesTied
        }
        
        if let teamColor = dictionary["teamColor"] as? String {
            self.teamColor = teamColor
        }
        
        if let league = dictionary["league"] as? League {
            self.league = league
        }
    }
    
    func getColor() -> UIColor {
        let colorParts = teamColor.characters.split{$0 == "|"}.map(String.init)
        let r: CGFloat = CGFloat((colorParts[0] as NSString).floatValue)
        let g: CGFloat = CGFloat((colorParts[1] as NSString).floatValue)
        let b: CGFloat = CGFloat((colorParts[2] as NSString).floatValue)
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    
}
