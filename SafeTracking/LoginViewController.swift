//
//  LoginViewController.swift
//  Needle
//
//  Created by Jasbeer on 09/07/19.
//  Copyright © 2019 DrillMaps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstallations
import FirebaseABTesting
import SystemConfiguration
import AuthenticationServices
import CryptoKit
import Security
import FlagPhoneNumber

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  private var isMFAEnabled = false
  var mobileNumber:String?
  var isValidMobileNumber = false
  
  @IBOutlet weak var email: FPNTextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var logoView: UIImageView!
  @IBOutlet weak var imageView: UIImageView!

  var rotateLeyoutRequired = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    handleViewEditingByTap()
    email.displayMode = .picker
    email.delegate = self
    loginButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    loginButton.layer.shadowOffset = CGSize(width: 0, height: -2)
    loginButton.layer.shadowOpacity = 1.0
    loginButton.layer.shadowRadius = 7
    loginButton.layer.cornerRadius = 7
    loginButton.layer.masksToBounds = false
    imageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
    imageView.layer.shadowOffset = CGSize(width: 0, height: -2)
    imageView.layer.shadowOpacity = 1.0
    imageView.layer.shadowRadius = 7
    imageView.layer.cornerRadius = 7
    imageView.layer.masksToBounds = false
    
    
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    // [END setup]
    Manager.shared.db = Firestore.firestore()
    
    UIDevice.current.isBatteryMonitoringEnabled = true
  }
  
  func textFieldShouldReturn(userText: UITextField) -> Bool {
    email.resignFirstResponder()
    return true;
  }
  
  override func viewWillAppear(_ animated: Bool) {
    loginButton.alpha = 0.0
    logoView.alpha = 0.0
    email.alpha = 0.0
  }
  
  override func viewDidAppear(_ animated: Bool) {
    //Moving the elements off-screen
    logoView.center.y -= view.bounds.width
    email.center.x -= view.bounds.width
    
    //Bringing back the login label with animation
    logoView.alpha = 1.0
    email.alpha = 1.0
    UIView.animate(withDuration: 1.0, animations: {
      self.logoView.center.y += self.view.bounds.width
      self.email.center.x += self.view.bounds.width
      
    })
    
    UIView.animate(withDuration: 1.0, delay: 0.4,
                   options: [],
                   animations: {
                    self.loginButton.alpha = 1.0
    }, completion: nil)
    
    rotateLeyoutRequired = true
  }
  
  @IBAction func terms(_ sender: UIButton) {
    
  }
  
  @IBAction func privacy(_ sender: UIButton) {
    
  }
  
  @IBAction func authenticateUser(_ sender: Any) {
    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    UserDefaults.standard.synchronize()
    
    Manager.shared.updateUserDetail()
    pendingVC()
//    phoneVerification()
  }
  
  func phoneVerification() {
    view.endEditing(true)
    guard let email = mobileNumber, isValidMobileNumber else {
      self.showAlert(message: "Please enter your valid Mobile Number")
      return
    }
    
    PhoneAuthProvider.provider().verifyPhoneNumber(email, uiDelegate: nil) { (verificationID, error) in
      // [START_EXCLUDE silent]
      
      // [END_EXCLUDE]
      if let error = error {
        self.showAlert(message: error.localizedDescription)
        return
      }
      // Sign in using the verificationID and the code sent to the user
      // [START_EXCLUDE]
      guard let verificationID = verificationID else { return }
      UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
      self.alertWithTextField(title: "Verification Code", message: "Please enter Verification Code", placeholder: "code", completion: { result in
        print(result)
      })
    }
  }
  
  public func alertWithTextField(title: String? = nil, message: String? = nil, placeholder: String? = nil, completion: @escaping ((String) -> Void) = { _ in }) {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addTextField() { newTextField in
      newTextField.placeholder = placeholder
      newTextField.isSecureTextEntry = true
      newTextField.keyboardType = UIKeyboardType.phonePad
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in completion("")})
    
    alert.addAction(UIAlertAction(title: "Resend", style: .default) { _ in
       self.phoneVerification()
      completion("")
    })
    
    alert.addAction(UIAlertAction(title: "Verify", style: .cancel) { action in
      if
        let textFields = alert.textFields,
        let tf = textFields.first,
        let verificationCode = tf.text
      { completion(verificationCode)
        KRProgressHUD.shared.show(withMessage: "Login...")
        if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
          
          
          // [START get_phone_cred]
          let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
          // [END get_phone_cred]
          
          Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
              print(error.localizedDescription)
              KRProgressHUD.dismiss()
              self.showAlert(message:"OTP entered is incorrect")
              return
            }
            
            if user != nil {
              UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
              UserDefaults.standard.synchronize()
              
              let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
              changeRequest?.displayName = self.mobileNumber
              changeRequest?.commitChanges { (error) in
                
                if let error = error {
                  KRProgressHUD.dismiss()
                  self.showAlert(message:error.localizedDescription)
                  return
                }
                self.pendingVC()
              }
            }
          }
        }
      }
      else
      { completion("") }
    })
    self.present(alert, animated: true)
  }
  
  
  func pendingVC() {
    DispatchQueue.main.async(execute: {
      let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
      if let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController {
        tabbar.modalPresentationStyle = .fullScreen
        tabbar.modalTransitionStyle = .flipHorizontal
        appDel.window?.rootViewController = tabbar
        appDel.window!.makeKeyAndVisible()
      }
    })
  }
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    return true
  }
  
  func handleViewEditingByTap() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing(gestureRecognizer:)))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc func endEditing(gestureRecognizer: UIGestureRecognizer) {
    view.endEditing(true)
  }
  
}

extension LoginViewController: FPNTextFieldDelegate {
  
  func fpnDisplayCountryList() {}
  
  func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
    textField.rightViewMode = .always
    //    textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
    
    mobileNumber = textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
    isValidMobileNumber = isValid
    
    print(
      isValid,
      textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
      textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
      textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
      textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
      textField.getRawPhoneNumber() ?? "Raw: nil"
    )
  }
  
  func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
    print(name, dialCode, code)
  }
}
