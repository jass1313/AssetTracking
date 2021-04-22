//
//  LocationManager.swift
//  DrillMaps
//
//  Created by Jasbeer on 15/07/19.
//  Copyright © 2019 DrillMaps. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import UIKit

class LocationManager: NSObject {
  
  static let shared = LocationManager()
  weak var delegate: LocationDelegate?
  
  fileprivate var isRunning = false
  private var manager: CLLocationManager!
  var latestLocation: CLLocation?
  private var captureTimer: Timer?
  
  override init() {
    super.init()
    // Create a location manager object
    self.manager = CLLocationManager()
    
    // Set the delegate
    self.manager.delegate = self
    
    // Request location authorization
    self.manager.requestAlwaysAuthorization()
    
    // Set an accuracy level. The higher, the better for energy.
    self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    
    // Enable automatic pausing
    self.manager.pausesLocationUpdatesAutomatically = false
    
    // Specify the type of activity your app is currently performing
    self.manager.activityType = .fitness
    
    // Enable background location updates
    self.manager.allowsBackgroundLocationUpdates = true
    
    self.manager.distanceFilter = 500
    
    manager.headingFilter = kCLHeadingFilterNone
    
    manager.showsBackgroundLocationIndicator = false
    
    manager.allowsBackgroundLocationUpdates = true
  }
  
  func requestInitialLocation() {
    latestLocation = nil
    manager.requestLocation()
  }
  
  func isLocationCapturing() -> Bool {
    return isRunning
  }
  
  ///startLocationUpdates
  func startBackgroundLocationUpdates() {
     isRunning = true
    
    /// Start location updates
//    self.manager.startUpdatingLocation()
    
    /// Start monitoring for visits
    self.manager.startMonitoringVisits()
    
    /// Start significant-change location updates
    self.manager.startMonitoringSignificantLocationChanges()
  }
  
  ///stoptLocationUpdates
  func stopBackgroundLocationUpdates() {
    isRunning = false
    if let manager = self.manager {
      manager.allowsBackgroundLocationUpdates = false
      
      /// Stop location updates
//      manager.stopUpdatingLocation()
      
       /// Stop monitoring for visits
      manager.stopMonitoringVisits()
      
      /// Stop significant-change location updates
      manager.stopMonitoringSignificantLocationChanges()
    }
  }
}

extension LocationManager: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    isRunning = false
    if let dlgt = delegate {
      dlgt.failedToUpdateLocation()
    }
  }
}

extension LocationManager {
  
  ///startVisitMonitoring
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
    
    // Get location description
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "Address: \(place)"
        self.newVisitReceived(visit, description: description)
      }
    }
  }
  
  
  ///startSignificantChangeLocationUpdates and startBackgroundLocationUpdates
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    
    AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "New visit: \(place)"
        
        let makeVisit = MakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
        self.newVisitReceived(makeVisit, description: description)
      }
    }
  }
  
  
  
  func newVisitReceived(_ visit: CLVisit, description: String) {
    let location = Location(visit: visit, descriptionString: description)
    
    LocationsStorage.shared.saveLocationOnDisk(location)
    
//    let content = UNMutableNotificationContent()
//    content.title = "New Location entry 📌"
//    content.body = location.description
//    content.sound = UNNotificationSound.default
//
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//    let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
//
//    AppDelegate().center.add(request, withCompletionHandler: nil)
  }
  
}

final class MakeVisit: CLVisit {
  private let myCoordinates: CLLocationCoordinate2D
  private let myArrivalDate: Date
  private let myDepartureDate: Date
  
  override var coordinate: CLLocationCoordinate2D {
    return myCoordinates
  }
  
  override var arrivalDate: Date {
    return myArrivalDate
  }
  
  override var departureDate: Date {
    return myDepartureDate
  }
  
  init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
    myCoordinates = coordinates
    myArrivalDate = arrivalDate
    myDepartureDate = departureDate
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
