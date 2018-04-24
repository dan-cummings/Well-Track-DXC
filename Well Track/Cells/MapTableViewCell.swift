//
//  MapTableViewCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/8/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MapTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var locType: UILabel!
    @IBOutlet weak var locTitle: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var data: LocationObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.tintColor = TEXT_DEFAULT_COLOR
        locType.textColor = TEXT_DEFAULT_COLOR
        locTitle.textColor = TEXT_DEFAULT_COLOR
        self.backgroundColor = BACKGROUND_COLOR
        timeLabel.textColor = TEXT_DEFAULT_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
