//
//  AlertDisplayable.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import UIKit

protocol AlertDisplayable {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]?)
}

extension AlertDisplayable where Self: UIViewController {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            actions.forEach { action in
                alertController.addAction(action)
            }
        } else {
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okButton)
        }
        present(alertController, animated: true)
    }
}
