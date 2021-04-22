
import UIKit
import CoreLocation
import FirebaseAuth

class Dashboard: UIViewController {
  
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var infectedBut: UIButton!
  @IBOutlet weak var logoutBut: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    startStopButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    startStopButton.layer.shadowOffset = CGSize(width: 0, height: -2)
    startStopButton.layer.shadowOpacity = 1.0
    startStopButton.layer.shadowRadius = 7
    startStopButton.layer.cornerRadius = 7
    startStopButton.layer.masksToBounds = false
    infectedBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    infectedBut.layer.shadowOffset = CGSize(width: 0, height: -2)
    infectedBut.layer.shadowOpacity = 1.0
    infectedBut.layer.shadowRadius = 7
    infectedBut.layer.cornerRadius = 7
    infectedBut.layer.masksToBounds = false
    logoutBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    logoutBut.layer.shadowOffset = CGSize(width: 0, height: -2)
    logoutBut.layer.shadowOpacity = 1.0
    logoutBut.layer.shadowRadius = 7
    logoutBut.layer.cornerRadius = 7
    logoutBut.layer.masksToBounds = false
    imageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    imageView.layer.shadowOffset = CGSize(width: 0, height: -2)
    imageView.layer.shadowOpacity = 1.0
    imageView.layer.shadowRadius = 7
    imageView.layer.cornerRadius = 7
    imageView.layer.masksToBounds = false
    
    Manager.shared.startObserving()
    let userAffected = UserDefaults.standard.bool(forKey: "affected?")
    infectedBut.setTitle(!userAffected ? "Are you Infected?" : "False Alarm", for: .normal)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    KRProgressHUD.dismiss()
    startStopLogs()
  }
  
  
  
  
  @IBAction func startStopLogs(_ sender: Any) {
    var locationUpdating = UserDefaults.standard.bool(forKey: "locationUpdating")
    UserDefaults.standard.set(!locationUpdating, forKey: "locationUpdating")
    locationUpdating = UserDefaults.standard.bool(forKey: "locationUpdating")
    startStopLogs()
    !locationUpdating ? LocationManager.shared.startBackgroundLocationUpdates() : LocationManager.shared.stopBackgroundLocationUpdates()
  }
  
  
  
  
  
  @IBAction func logout(_ sender: Any) {
    let alert = UIAlertController(title: NSLocalizedString("Logout \(Auth.auth().currentUser?.displayName ?? "")", comment: "Warning!"),
                                  message: NSLocalizedString("Are you sure to logout?", comment: "Save alert title"), preferredStyle: .alert)
    
    let yesAction = UIAlertAction(title: NSLocalizedString("Logout", comment: "Yes title"), style: .default, handler: { (action) in
      Manager.shared.logout()
    })
    alert.addAction(yesAction)
    
    let noAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "No title"), style: .cancel, handler: nil)
    alert.addAction(noAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  
  
  
  
  func startStopLogs() {
    let locationUpdating = UserDefaults.standard.bool(forKey: "locationUpdating")
    
    if locationUpdating {
      startStopButton.setTitle("Start Logs", for: .normal)
      startStopButton.backgroundColor = UIColor.init(red: 21/255, green: 204/255, blue: 21/255, alpha: 1)
    } else {
      authorizationStatus()
      startStopButton.setTitle("Stop Logs", for: .normal)
      startStopButton.backgroundColor = UIColor.red
    }
  }
  
  
  
  
  @IBAction func affected(_ sender: Any) {
    let userAffected = UserDefaults.standard.bool(forKey: "affected?")
    
    if userAffected {
      UserDefaults.standard.set(false, forKey: "affected?")
      Manager.shared.getDrillRef()?.removeValue()
      showAlertMessage(message: "Congratulation")
      infectedBut.setTitle("Are you Infected?", for: .normal)
    } else {
      guard LocationsStorage.shared.locations.count > 0 else {
        showAlertMessage(message: "Your visited places is empty")
        return
      }
      areYouAffectedWithVirus()
    }
  }
  
  
  
  
  func areYouAffectedWithVirus() {
    
    let alert = UIAlertController(title: NSLocalizedString("Alert!", comment: "Warning!"),
                                  message: NSLocalizedString("Are you infected by Virus?",
                                                             comment: "Save alert title"), preferredStyle: .alert)
    
    
    let yesAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes title"),
                                  style: .default, handler: { (action) in
                                    
                                    
      let alert = UIAlertController(title: NSLocalizedString("Are you sure ?", comment: "Are you sure ?"),
                                    message: NSLocalizedString("Ony location data will be shared, phone number awill not be shared. Do you want to continue?",
                                                               comment: "Save alert title"), preferredStyle: .alert)
      
      
      let Confirm = UIAlertAction(title: NSLocalizedString("Confirm", comment: "Yes title"), style: .default, handler: { (action) in
        
//        Manager.shared.saveDrill() { (err, ref) in}
        UserDefaults.standard.set(true, forKey: "affected?")
        self.infectedBut.setTitle("False Alarm", for: .normal)
      })
      
      alert.addAction(Confirm)
      
      let no = UIAlertAction(title: NSLocalizedString("No", comment: "No title"), style: .cancel, handler: nil)
      alert.addAction(no)
      
      self.present(alert, animated: true, completion: nil)
    })
    alert.addAction(yesAction)
    
    let noAction = UIAlertAction(title: NSLocalizedString("No", comment: "No title"), style: .cancel, handler: nil)
    alert.addAction(noAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  
  func authorizationStatus() {
    if CLLocationManager.authorizationStatus() == .denied {
      let alert = UIAlertController(title: NSLocalizedString("Alert!", comment: "Warning!"),
                                    message: NSLocalizedString("Tap on Authorize and then Change Location from 'Never' to 'Always'",comment: "Save alert title"), preferredStyle: .alert)
      
      let yesAction = UIAlertAction(title: NSLocalizedString("Authorize", comment: "Yes title"),style: .cancel, handler: { (action) in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open( url)
        }
      })
      alert.addAction(yesAction)
      
      present(alert, animated: true, completion: nil)
      
    } else if CLLocationManager.authorizationStatus() != .authorizedAlways {
      let alert = UIAlertController(title: NSLocalizedString("Alert!", comment: "Warning!"),
                                    message: NSLocalizedString("Please tap on Authorize Always for location updates",comment: "Save alert title"), preferredStyle: .alert)
      
      let yesAction = UIAlertAction(title: NSLocalizedString("Authorize Always", comment: "Yes title"),style: .cancel, handler: { (action) in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open( url)
        }
      })
      alert.addAction(yesAction)
      
      let noAction = UIAlertAction(title: NSLocalizedString("Skip", comment: "Yes title"),style: .destructive, handler: { (action) in
        self.showAlertMessage(message: "You will not receive Location Updates")
      })
      alert.addAction(noAction)
      
      present(alert, animated: true, completion: nil)
      
    }
  }
}

