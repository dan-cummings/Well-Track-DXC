//
//  WellTrackMediaCollectionViewCell.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class WellTrackMediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    var data: MediaItems!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
