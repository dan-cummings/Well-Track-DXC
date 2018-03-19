//
//  Settings.swift
//  Well Track
//
//  Created by Carolyn Quigley on 2/24/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation

struct Settings {
    var key: String?
    var minTemp: String?
    var maxTemp: String?
    var minHeart: String?
    var maxHeart: String?
    var hours: String?
    var minutes: String?
    var gps: Int
    var alert: Int

    init(key: String?, minTemp: String?, maxTemp: String?, minHeart: String?, maxHeart: String?, hours: String?, minutes: String?, gps: Int, alert: Int) {
        self.key = key
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.minHeart = minHeart
        self.maxHeart = maxHeart
        self.hours = hours
        self.minutes = minutes
        self.gps = gps
        self.alert = alert
    }
    init(minTemp: String?, maxTemp: String?, minHeart: String?, maxHeart: String?, hours: String?, minutes: String?, gps: Int, alert: Int) {
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.minHeart = minHeart
        self.maxHeart = maxHeart
        self.hours = hours
        self.minutes = minutes
        self.gps = gps
        self.alert = alert
    }
    init() {
        self.key = nil
        // should probably have default values
        self.minTemp = ""
        self.maxTemp = ""
        self.minHeart = ""
        self.maxHeart = ""
        self.hours = ""
        self.minutes = ""
        // default to on or off?
        self.gps = 1
        self.alert = 1
    }
}
