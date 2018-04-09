//
//  MediaItems.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation

struct MediaItems {
    
    var key: String?
    var videoURL: String?
    var duration: Double?
    var imageURL: String?
    
    init(key: String?, videoURL: String?, duration: Double?, imageURL: String?) {
        self.key = key
        self.videoURL = videoURL
        self.duration = duration
        self.imageURL = imageURL
    }
    init() {
        self.key = nil
        self.videoURL = ""
        self.duration = 0.0
        self.imageURL = ""
    }
}
