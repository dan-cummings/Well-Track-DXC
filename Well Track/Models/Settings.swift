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
    var nokiaAccount: Int
    var authToken: String?
    var authSec: String?
    var userID: String?

    init(key: String?, minTemp: String?, maxTemp: String?, minHeart: String?, maxHeart: String?, hours: String?, minutes: String?, gps: Int, alert: Int, nokiaAccount: Int, authToken: String?, authSec: String?, userID: String?) {
        self.key = key
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.minHeart = minHeart
        self.maxHeart = maxHeart
        self.hours = hours
        self.minutes = minutes
        self.gps = gps
        self.alert = alert
        self.nokiaAccount = nokiaAccount
        self.authSec = authSec
        self.authToken = authToken
        self.userID = userID
    }
    
    init(minTemp: String?, maxTemp: String?, minHeart: String?, maxHeart: String?, hours: String?, minutes: String?, gps: Int, alert: Int, nokiaAccount: Int, authToken: String?, authSec: String?, userID: String?) {
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.minHeart = minHeart
        self.maxHeart = maxHeart
        self.hours = hours
        self.minutes = minutes
        self.gps = gps
        self.alert = alert
        self.nokiaAccount = nokiaAccount
        self.authSec = authSec
        self.authToken = authToken
        self.userID = userID
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
        self.nokiaAccount = 0
        self.authToken = ""
        self.authSec = ""
        self.userID = ""
    }
}
