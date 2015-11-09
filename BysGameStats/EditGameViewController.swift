//
//  EditGameViewController.swift
//  BysGameStats
//
//  Created by James Tench on 11/7/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit
import Parse
import CoreData

class EditGameViewController: UIViewController {

    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var homeTeamScore: UITextField!
    @IBOutlet weak var awayTeamScore: UITextField!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var statusMessage: UILabel!

    var game: Game?
    var coachType: String?
    var canEdit = false
    var canConfirm = false
    
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
        guard let currentGame = self.game else {
            self.popUserToPriorView()
            return
        }
        guard let homeTeam = currentGame.homeTeam else {
            self.popUserToPriorView()
            return
        }
        guard let awayTeam = currentGame.awayTeam else {
            self.popUserToPriorView()
            return
        }
        guard let coachType = self.coachType else {
            popUserToPriorView()
            return
        }
        
        if let _ = PFUser.currentUser() {
            submitButton.hidden = true
            submitButton.enabled = false
            
            if coachType == "homeTeamCoach" && currentGame.status != "confirmed" {
                canEdit = true
            } else if coachType == "awayTeamCoach" && currentGame.status == "complete" {
                canConfirm = true
            }
            
            if currentGame.status == "scheduled" {
                if canEdit {
                    submitButton.enabled = true
                    submitButton.hidden = false
                    submitButton.titleLabel?.text = "Submit"
                    statusMessage.text = "Update game score and click submit to save."
                } else if canConfirm {
                    statusMessage.text = "Scores must be input by the Home team coach."
                } else {
                    statusMessage.text = "If this game has been completed, contact home team coach to update scores."
                }
            } else if currentGame.status == "complete" {
                if canEdit {
                    submitButton.enabled = true
                    submitButton.hidden = false
                    submitButton.titleLabel?.text = "Submit"
                    statusMessage.text = "Update game score and click submit to save."
                } else if canConfirm {
                    submitButton.enabled = true
                    submitButton.hidden = false
                    submitButton.titleLabel?.text = "Confirm"
                    statusMessage.text = "Click Confirm to finalize game score. If there is a discrepancy, please contact the home team coach"
                }
            } else {
                statusMessage.text = "This game is final. Contact league commissioner for discrepancies"
            }
            
            homeTeamLabel.text = homeTeam.teamName
            awayTeamLabel.text = awayTeam.teamName
            homeTeamScore.text = "\(currentGame.homeTeamScore)"
            awayTeamScore.text = "\(currentGame.awayTeamScore)"
            gameStatusLabel.text = currentGame.status
            
            
        } else {
            // user shouldn't be here...pop them back
            popUserToPriorView()
        }
    }
    
    func updateGameScore() {
        guard let homeTeamScoreText = homeTeamScore.text else {
            // todo: print some error if empty
            return
        }
        guard let homeTeamScore = Int(homeTeamScoreText) else {
            // todo: tell user not an integer in home team field
            return
        }
        guard let awayTeamScoreText = awayTeamScore.text else {
            // todo: print some error if empty
            return
        }
        guard let awayTeamScore = Int(awayTeamScoreText) else {
            // todo: tell user not an integer in home team field
            return
        }
        
        let parseGame = PFObject(withoutDataWithClassName: "Game", objectId: game?.objectId)
        parseGame.setObject(homeTeamScore, forKey: "homeTeamScore")
        parseGame.setObject(awayTeamScore, forKey: "awayTeamScore")
        parseGame.setObject("complete", forKey: "status")
        parseGame.saveInBackground()
    }
    
    func confirmGameScore() {

    }
    
    @IBAction func submitButtonTouchUp(sender: UIButton) {
        if sender.titleLabel?.text == "Submit" {
            updateGameScore()
        } else {
            confirmGameScore()
        }
        
        
    }
    
    func popUserToPriorView() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
}




































