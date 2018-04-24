//
//  WellTrackTableViewCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class WellTrackTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var thermoImage: UIImageView!
    @IBOutlet weak var heartImage: UIImageView!
    @IBOutlet weak var pointerImage: UIImageView!
    
    /// Log being used to populate views in the cell.
    var log: HealthLog?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = BACKGROUND_COLOR
        temperatureLabel.textColor = TEXT_DEFAULT_COLOR
        thermoImage.tintColor = TEXT_DEFAULT_COLOR
        moodImage.tintColor = TEXT_DEFAULT_COLOR
        heartImage.tintColor = TEXT_DEFAULT_COLOR
        pointerImage.tintColor = TEXT_DEFAULT_COLOR
        heartRateLabel.textColor = TEXT_DEFAULT_COLOR
        moodLabel.textColor = TEXT_DEFAULT_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
