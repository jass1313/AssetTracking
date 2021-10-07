

import UIKit
import MapKit
import GeoFire
import Firebase
import PromiseKit

class MapViewController: UIViewController,MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  var geoFire:GeoFire!
  var userLocation:CLLocation?
  var geoFireRef: DatabaseReference?
  let ref = Database.database().reference().child("infected")
  var queryDistance = 200.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.userTrackingMode = .follow
    mapView.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "updateUI"), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    updateData()
  }
  
  @IBAction func addItemPressed(_ sender: Any) {
    sendLocation()
  }
  
  @objc func updateData() {
    let annotations = Manager.shared.allCovidData.map { annotationForLocation($0) }
      mapView.addAnnotations(annotations)
  }
  
  func annotationForLocation(_ location: Covid) -> MKAnnotation {
    let annotation = MKPointAnnotation()
    annotation.title = String(location.address)
    if location.latLng.count == 2 {
      annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: location.latLng[0]), longitude: CLLocationDegrees(truncating: location.latLng[1]))
    }
    return annotation
  }
  
  func sendLocation() {
    guard let currentLocation = mapView.userLocation.location else {
      return
    }
    LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
  }
  
  func checkInternet() {
    guard ReachabilityManager.isConnectedToNetwork() else {
      self.showAlert(message: "No internet connection")
      return
    }
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    if let loc = userLocation.location {
      self.userLocation = loc
      //      _ = liveLocationMatchQuery(location: loc)
    }
  }
  
  func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // Leave default annotation for user location
    if annotation is MKUserLocation {
      return nil
    }
    
    let reuseID = "Location"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
    
    if annotationView == nil {
      let pin = MKAnnotationView(annotation: annotation,reuseIdentifier: reuseID)
      pin.image = UIImage(named: "Marker")
      pin.isEnabled = true
      pin.canShowCallout = true
      
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
      label.textColor = .black
      pin.addSubview(label)
      annotationView = pin
    } else {
      annotationView?.annotation = annotation
    }
    
    return annotationView
  }
}
