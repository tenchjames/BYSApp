//
//  GameTableViewCell.swift
//  BysGameStats
//
//  Created by James Tench on 10/31/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamScore: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamScore: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
