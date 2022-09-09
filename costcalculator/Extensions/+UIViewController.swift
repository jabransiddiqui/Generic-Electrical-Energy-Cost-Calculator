//
//  +UIViewController.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    func showAlert(withTitle title: String, message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (alert) in
            guard let completion = completion else {
                return
            }
            completion()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
