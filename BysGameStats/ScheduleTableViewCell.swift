//
//  ScheduleTableViewCell.swift
//  BysGameStats
//
//  Created by James Tench on 11/1/15.
//  Copyright © 2015 James Tench. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
