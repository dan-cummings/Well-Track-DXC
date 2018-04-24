//
//  MapTableViewHeaderCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 4/23/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class MapTableViewHeaderCell: UITableViewCell {
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
