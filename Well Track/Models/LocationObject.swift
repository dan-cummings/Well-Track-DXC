//
//  LocationObject.swift
//  Well Track
//
//  Created by Daniel Cummings on 3/8/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import Foundation

struct LocationObject {
    
    var lat: Double
    var lon: Double
    var snippet: String
    var name: String
    var type: String
    var from: Date
    var to: Date
    
    init(lat: Double, lon: Double, snippet: String, name: String, type: String, from: Date, to: Date) {
        self.lat = lat
        self.lon = lon
        self.snippet = snippet
        self.name = name
        self.type = type
        self.from = from
        self.to = to
    }
}
