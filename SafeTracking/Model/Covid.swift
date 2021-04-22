

import UIKit
import Firebase
import CoreLocation

class Covid: NSObject {
  var key:String?
  var lat = CLLocationDegrees()
  var lng = CLLocationDegrees()
  var createdAt:TimeInterval
  var address = String()
  var latLng = [NSNumber]()
  
  init(lat:CLLocationDegrees,lng:CLLocationDegrees,createdAt:TimeInterval,address: String,latlng:[NSNumber]) {
    self.lat = lat
    self.lng = lng
    self.createdAt = createdAt
    self.address = address
    self.latLng = latlng
    }
  
  init(snapshot: DataSnapshot) {
      key = snapshot.key
      let snapshotValue = snapshot.value as! [String: AnyObject]
      createdAt = snapshotValue["createdAt"] as? TimeInterval ?? 0
      address = snapshotValue["address"] as? String ?? ""
      latLng = snapshotValue["l"] as? [NSNumber] ?? [0,0]
     
  }
}
