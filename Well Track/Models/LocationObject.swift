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
    
    init(lat: Double, lon: Double, snippet: String, name: String) {
        self.lat = lat
        self.lon = lon
        self.snippet = snippet
        self.name = name
    }
}
