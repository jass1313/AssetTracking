
import Foundation
import Firebase
import CoreLocation
import GeoFire
import Reachability
import SystemConfiguration

class Manager: NSObject {
  
  var geoFire:GeoFire!
  static let shared = Manager()
  var allCovidData = [Covid]()
  var db: Firestore!
  fileprivate let refDatabase = Database.database().reference(withPath: "LocationHistory")
  
  func startObserving() {
    guard let ref = getDrillRef() else {
      return
    }
    ref.keepSynced(true)
    var query = DatabaseQuery()
    query = ref
    
    query.observe(.value, with: { snapshot in
    
        var newItems = [Covid]()
        
        for item in snapshot.children {
            let drillItem = Covid(snapshot: item as! DataSnapshot)
            newItems.append(drillItem)
        }
        
        self.allCovidData = newItems
      
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUI"), object: nil)
    }){ (error) in
      print(error.localizedDescription)
  }
  }
  
  func stopObserving() {
    refDatabase.removeAllObservers()
  }
  
  func saveDrill(lastLocationUpdate:Location,count:Int,completionHandler: @escaping (Error?, DatabaseReference) -> Void ) {
    
    guard  LocationsStorage.shared.locations.count > 0 else {
      completionHandler(NSError(domain:"com.drillmaps.SelfTracking", code: 1, userInfo:nil), refDatabase)
      return
    }
    
    if let drillRef = getDrillRef(), let uuid = UIDevice.current.identifierForVendor?.uuidString {
      geoFire = GeoFire(firebaseRef: refDatabase.child(uuid))
      
      var uploadValues = [String: Any]()
        
        let ref = drillRef.child("\(count)")
        
        uploadValues["createdAt"] = lastLocationUpdate.date.timeIntervalSince1970
        uploadValues["address"] = lastLocationUpdate.description
        uploadValues["lat"] = lastLocationUpdate.latitude
        uploadValues["lng"] = lastLocationUpdate.longitude
        
        ref.updateChildValues(uploadValues)
        
        geoFire.setLocation(CLLocation(latitude: lastLocationUpdate.latitude, longitude: lastLocationUpdate.longitude), forKey: "\(count)")
      
      uploadValues.removeAll()
      
      drillRef.updateChildValues(uploadValues, withCompletionBlock: { (error, ref) in
        completionHandler(error, ref)})
    }
  }
  
  func saveDrill(completionHandler: @escaping (Error?, DatabaseReference) -> Void ) {
    
    guard  LocationsStorage.shared.locations.count > 0 else {
      completionHandler(NSError(domain:"com.drillmaps.SelfTracking", code: 1, userInfo:nil), refDatabase)
      return
    }
    
    if let drillRef = getDrillRef(), let uuid = UIDevice.current.identifierForVendor?.uuidString {
      geoFire = GeoFire(firebaseRef: refDatabase.child("\(uuid)"))
      
      var uploadValues = [String: Any]()
      var count = 0
      
      for coord in LocationsStorage.shared.locations {
        
        let ref = drillRef.child("\(count)")
        
        uploadValues["createdAt"] = coord.date.timeIntervalSince1970
        uploadValues["address"] = coord.description
        uploadValues["lat"] = coord.latitude
        uploadValues["lng"] = coord.longitude
        
        ref.updateChildValues(uploadValues)
        
//        geoFire.setLocation(CLLocation(latitude: coord.latitude, longitude: coord.longitude), forKey: "\(count)")
        count = count + 1
      }
      
      uploadValues.removeAll()
      
      drillRef.updateChildValues(uploadValues, withCompletionBlock: { (error, ref) in
        completionHandler(error, ref)})
    }
  }
  
  func getDrillRef() -> DatabaseReference? {
    if let deviceid = UIDevice.current.identifierForVendor?.uuidString {
      return Database.database().reference().child("LocationHistory").child(deviceid)
    }
    return nil
  }
  
  //write or Update customer details
  func updateUserDetail() {
      // [START update_document]
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
          let customerRef = db.collection("deviceList").document(uuid)
          customerRef.setData([
            "battery": UIDevice.current.batteryLevel,
            "createdat": Date.timeIntervalSinceReferenceDate,
            "id": uuid,
            "name": UIDevice.current.name
        ]) { err in
              if let err = err {
                  print("Error updating document: \(err)")
              } else {
                  print("Document successfully updated")
              }
          }
          // [END update_document]
      }
  }

  func logout() {
    do {
      try Auth.auth().signOut()
      stopObserving()
      LocationManager.shared.stopBackgroundLocationUpdates()
      
      UserDefaults.standard.set("", forKey: "authVerificationID")
      UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
      UserDefaults.standard.set(true, forKey: "locationUpdating")
      UserDefaults.standard.synchronize()
      
      let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
      let loginVC = storyBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
      let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
      UIView.transition(with: appDel.window!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight, animations: {
        appDel.window?.rootViewController = loginVC
      }, completion: nil)
      
    } catch let err {
      print(err)
    }
  }
}

public class ReachabilityManager {
  
  class func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }
    
    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
    
  }
}

//ManualDataEntertodatabase
func manualDataEnter() {
  let dispatchGroup = DispatchGroup()
  let dispatchQueue = DispatchQueue(label: "any-label-name")
  let dispatchSemaphore = DispatchSemaphore(value: 0)
  var count = 0
  dispatchQueue.async {
    
    for loc in allManualData {
      dispatchGroup.enter()
      
      let location = CLLocation(latitude: loc[0], longitude: loc[1])
      
      AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
        if let place = placemarks?.first {
          let description = "New visit: \(place)"
          
          let makeVisit = MakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
          LocationManager.shared.newVisitReceived(makeVisit, description: description)
          dispatchSemaphore.signal()
          dispatchGroup.leave()
          count=count+1
          print(count)
        }
      }
      dispatchSemaphore.wait()
    }
  }
  
  dispatchGroup.notify(queue: dispatchQueue) {
    DispatchQueue.main.async {
      print("done")
    }
  }
}

///ManualDataArray
let allManualData = [
  [28.772868, 77.514877],
]
