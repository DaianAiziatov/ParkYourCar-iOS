//
//  SplashViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.splashTimeOut(sender:)), userInfo: nil, repeats: false)
    }
    
    @objc func splashTimeOut(sender : Timer) {
        // TODO: Check if the user is already loggedin then direct to Home instead Login
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "startNavigationVC")
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
    }
    
    
}
