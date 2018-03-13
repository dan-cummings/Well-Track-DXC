//
//  LogModel.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation

struct HealthLog {
    var key: String?
    var date: Date?
    var temperature: String
    var heartrate: String
    var moodrating: String
    var hasText: Int
    var text: String?
    var hasPicture: Int
    var hasVideo: Int
    var hasLocation: Int
    var latitude: Float?
    var longitude: Float?
    
    init(key: String?, date: Date?, temperature: String, heartrate: String, moodrating: String, hasText: Int, text: String?, hasPicture: Int, hasVideo: Int, hasLocation: Int, latitude: Float?, longitude: Float?) {

        self.key = key
        self.date = date
        self.temperature = temperature
        self.heartrate = heartrate
        self.moodrating = moodrating
        self.hasText = hasText
        self.text = text
        self.hasPicture = hasPicture
        self.hasVideo = hasVideo
        self.hasLocation = hasLocation
        self.latitude = latitude
        self.longitude = longitude
    }
    init( date: Date?, temperature: String, heartrate: String, moodrating: String, hasText: Int, text: String?, hasPicture: Int, hasVideo: Int, hasLocation: Int, latitude: Float?, longitude: Float?) {
        self.date = date
        self.temperature = temperature
        self.heartrate = heartrate
        self.moodrating = moodrating
        self.hasText = hasText
        self.text = text
        self.hasPicture = hasPicture
        self.hasVideo = hasVideo
        self.hasLocation = hasLocation
        self.latitude = latitude
        self.longitude = longitude
    }
    init() {
        self.key = nil
        self.date = nil
        self.temperature = ""
        self.heartrate = ""
        self.moodrating = ""
        self.hasText = 0
        self.text = ""
        self.hasPicture = 0
        self.hasVideo = 0
        self.hasLocation = 0
        self.latitude = nil
        self.longitude = nil
    }
}
