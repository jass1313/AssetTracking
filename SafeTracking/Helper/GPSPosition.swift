//
//  GPSPosition.swift
//  BM
//
//  Created by Satyanarayana on 22/12/17.
//  Copyright © 2017 Satyam. All rights reserved.
//

import Foundation

class GPSPosition {
    var time: Double
    var latitude: Double
    var longitude: Double
    var fixed: Bool
    var quality: Int
    var satellites: Int
    var dir: Double
    var altitude: Double
    var velocity: Double
    var accuracy: Double
    
    init() {
        time = 0.0
        latitude = 0.0
        longitude = 0.0
        fixed = false
        quality = 0
        satellites = 0
        dir = 0.0
        altitude = 0.0
        velocity = 0.0
        accuracy = 0.0
    }
    
    func updateFix() {
        fixed = quality > 0
    }
}

