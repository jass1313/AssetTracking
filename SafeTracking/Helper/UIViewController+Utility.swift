//
//  UIViewController+Utility.swift
//  DrillMaps
//
//  Created by Jasbeer Singh on 09/07/19.
//  Copyright © 2019 DrillMaps. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showSuccessAlert(message:String) {
        
        let alert = UIAlertController(title: NSLocalizedString("Successful!", comment: "Successful title"), message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlertAndDismissModal(title: String = NSLocalizedString("Successful!", comment: "Successful title"), message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlertAndDismiss(title: String = NSLocalizedString("Successful!", comment: "Successful title"), message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default) { (action) in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(message:String) {
        
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning title"), message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertMessage(message:String) {
       
       let alert = UIAlertController(title: NSLocalizedString("Message", comment: "Warning title"), message: message, preferredStyle: .alert)
       let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default, handler: nil)
       alert.addAction(alertAction)
       
       present(alert, animated: true, completion: nil)
   }
    
    func showAlertAndDismissModal(message:String) {
        
        let alert = UIAlertController(title: NSLocalizedString("Warning!", comment: "Warning title"), message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertAndDismiss(title: String = NSLocalizedString("Warning!", comment: "Warning title"), message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK title"), style: .default) { (action) in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
}
