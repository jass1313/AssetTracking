

//
//  LocationDelegate.swift
//  DrillMaps
//
//  Created by Jasbeer on 15/07/19.
//  Copyright © 2019 DrillMaps. All rights reserved.
//

import Foundation

protocol LocationDelegate: NSObjectProtocol {
    func failedToUpdateLocation()
    func didUpdateToLocation(_ position: GPSPosition)
}

extension LocationDelegate {
    func failedToUpdateLocation() {
        
    }
    
    func didUpdateToLocation(_ position: GPSPosition) {
        
    }
}
