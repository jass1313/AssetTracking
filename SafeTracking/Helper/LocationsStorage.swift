

import Foundation
import CoreLocation

class LocationsStorage {
  static let shared = LocationsStorage()
  
  private(set) var locations: [Location]
  private let fileManager: FileManager
  private var documentsURL: URL
  
  init() {
    let fileManager = FileManager.default
    documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)    
    self.fileManager = fileManager
    
    let jsonDecoder = JSONDecoder()
    
    let locationFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL,
                                                                 includingPropertiesForKeys: nil)
    locations = locationFilesURLs.compactMap { url -> Location? in
      guard !url.absoluteString.contains(".DS_Store") else {
        return nil
      }
      guard let data = try? Data(contentsOf: url) else {
        return nil
      }
      return try? jsonDecoder.decode(Location.self, from: data)
    }.sorted(by: { $0.date < $1.date })
    
    self.cleanUp(days: 7)
  }
  
  func saveCLLocationToDisk(_ clLocation: CLLocation) {
    self.cleanUp(days: 7)
    
    let currentDate = Date()
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "\(place)")
        
        self.saveLocationOnDisk(location)
      }
    }
  }
  
  
  func saveLocationOnDisk(_ location: Location) {
    
    let encoder = JSONEncoder()
    let timestamp = location.date.timeIntervalSince1970
    let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
    
    let data = try! encoder.encode(location)
    try! data.write(to: fileURL)
    
    locations.append(location)
    
    NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])
    Manager.shared.saveDrill() { (err, ref) in}
  }
  
  func cleanUp(days:Double) {
    if days == 0 { locations.removeAll() } 
    let maximumDays = days ///days
    let minimumDate = Date().addingTimeInterval(-maximumDays*24*60*60)
    func meetsRequirement(date: Date) -> Bool { return date < minimumDate }
    
    do {
      let manager = FileManager.default
      let documentDirUrl = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      
      
      //delete out of date locations
      if manager.changeCurrentDirectoryPath(documentDirUrl.path) {
        for file in try manager.contentsOfDirectory(atPath: ".") {
          let creationDate = try manager.attributesOfItem(atPath: file)[FileAttributeKey.creationDate] as! Date
          if meetsRequirement(date: creationDate) {
            try manager.removeItem(atPath: file)
          }
        }
      }
      
      
      //refresh location array
      let jsonDecoder = JSONDecoder()
      let locationFilesURLs = try! manager.contentsOfDirectory(at: documentDirUrl,includingPropertiesForKeys: nil)
      locations = locationFilesURLs.compactMap { url -> Location? in
        guard !url.absoluteString.contains(".DS_Store") else {
          return nil
        }
        guard let data = try? Data(contentsOf: url) else {
          return nil
        }
        return try? jsonDecoder.decode(Location.self, from: data)
      }.sorted(by: { $0.date < $1.date })
      
      
    }
    catch {
      print("Cannot cleanup the old files: \(error)")
    }
  }
  
}

extension Notification.Name {
  static let newLocationSaved = Notification.Name("newLocationSaved")
}

