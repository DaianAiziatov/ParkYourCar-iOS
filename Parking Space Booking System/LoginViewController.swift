//
//  ViewController.swift
//  Parking Space Booking System
//
//  Created by Tasneem Bohra on 2018-11-01.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = sb.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController
        //TODO: validation
        self.navigationController?.pushViewController(homeVC!, animated: true)
    }
    
    
    @IBAction func signUp(_ sender: Any) {
    }
    
}

