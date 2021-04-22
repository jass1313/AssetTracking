//
//  FeedbackViewController.swift
//  DrillMaps
//
//  Created by Satyanarayana on 19/02/17.
//  Copyright © 2017 Drill Maps. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class FeedbackViewController: UITableViewController {
    
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.14).cgColor
        submitButton.layer.shadowOffset = CGSize(width: 0, height: -2)
        submitButton.layer.shadowOpacity = 1.0
        submitButton.layer.shadowRadius = 7
        submitButton.layer.cornerRadius = 7
        submitButton.layer.masksToBounds = false
    }

    
    @IBAction func submitFeedback() {
        view.endEditing(true)
        
        guard ReachabilityManager.isConnectedToNetwork() else {
          self.showAlert(message: "You cannot update info while offline")
          return
        }
        
        guard let sub = subject.text, let comment = comments.text, sub != "", comment != "" else {
            self.showAlert(message: NSLocalizedString("Subject & Comments are required fields", comment: "Feedback warning message"))
            return
        }
        
        if let usr = Auth.auth().currentUser {
            KRProgressHUD.show(withMessage: "Loading...")
            
            let ref = Database.database().reference()
            let userFeedback = ["userId": usr.uid,
                                "userFeedbackTime": Date().timeIntervalSince1970,
                                "Username": usr.displayName ?? "",
                                "userFeedbackSubject": sub,
                                "userFeedbackComments": comment] as [String : Any]
          
          if let key = ref.child("user_feedback").childByAutoId().key {
            let childUpdates = ["/user_feedback/\(key)": userFeedback]
            
            ref.updateChildValues(childUpdates, withCompletionBlock: { (err, ref) in
                KRProgressHUD.dismiss()
                if let error = err {
                    self.showAlert(message: error.localizedDescription)
                } else {
                  self.subject.text = ""
                  self.comments.text = ""
                  self.showSuccessAlert(message: "Successfull sent your feedback")
                }
            })
          }
        } else {
            self.showAlert(message: NSLocalizedString("Your login session is expired. Please login again", comment: "Session expired warning"))
        }
    }
}
