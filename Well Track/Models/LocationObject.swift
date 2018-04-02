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
    var name: String
    var type: String
    var startDate: Date?
    var endDate: Date?
    
    init(key: String, lat: Double, lon: Double, name: String, type: String, startDate: Date?, endDate: Date?) {
        self.key = key
        self.lat = lat
        self.lon = lon
        self.name = name
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
    }
    
    init() {
        self.key = ""
        self.lat = 0.0
        self.lon = 0.0
        self.name = ""
        self.type = ""
        self.startDate = nil
        self.endDate = nil
    }
}
