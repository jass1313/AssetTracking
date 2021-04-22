

import UIKit
import UserNotifications
import FirebaseAuth
import Firebase

class PlacesTableViewController: UITableViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self,selector: #selector(newLocationAdded(_:)),name: .newLocationSaved,object: nil)
  }
  
  @IBAction func logout(_ sender: Any) {
    LocationsStorage.shared.cleanUp(days: 0)
    Manager.shared.getDrillRef()?.removeValue()
    tableView.reloadData()
  }
  
  @objc func newLocationAdded(_ notification: Notification) {
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return LocationsStorage.shared.locations.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
    let location = LocationsStorage.shared.locations[indexPath.row]
    cell.textLabel?.numberOfLines = 3
    cell.textLabel?.text = location.description
    cell.detailTextLabel?.text = location.dateString
    Manager.shared.saveDrill(lastLocationUpdate: location, count: indexPath.row) { (err, ref) in}

    // Configure the cell...
       let maskLayer = CAShapeLayer()
       let bounds = cell.bounds
       maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: bounds.width-4, height: bounds.height-1), cornerRadius: 5).cgPath
       cell.layer.mask = maskLayer
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 110
  }
}
