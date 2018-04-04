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
    var data: LocationObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
