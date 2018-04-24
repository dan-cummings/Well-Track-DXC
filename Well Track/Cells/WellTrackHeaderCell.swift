//
//  WellTrackHeaderCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 4/22/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class WellTrackHeaderCell: UITableViewCell {

    @IBOutlet weak var section: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        section.textColor = TEXT_HIGHLIGHT_COLOR
        self.backgroundColor = HEADER_BACKGROUND_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
