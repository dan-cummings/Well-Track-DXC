//
//  LocationObject.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/8/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation

struct LocationObject {
    
    var key: String?
    var lat: Double
    var lon: Double
    var placeID: String
    var name: String
    var type: String
    var date: Date?
    
    init(key: String, lat: Double, lon: Double, placeID: String, name: String, type: String, date: Date) {
        self.key = key
        self.lat = lat
        self.lon = lon
        self.placeID = placeID
        self.name = name
        self.type = type
        self.date = date
    }
    
    init() {
        self.key = ""
        self.lat = 0.0
        self.lon = 0.0
        self.placeID = ""
        self.name = ""
        self.type = ""
        self.date = nil
    }
}
