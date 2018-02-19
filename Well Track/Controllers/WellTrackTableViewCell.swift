//
//  WellTrackTableViewCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class WellTrackTableViewCell: UITableViewCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    
    var log: HealthLog?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
