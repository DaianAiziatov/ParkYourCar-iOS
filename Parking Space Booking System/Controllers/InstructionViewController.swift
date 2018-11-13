//
//  InstructionViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import WebKit

class InstructionViewController: UIViewController {

    @IBOutlet weak var myWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromFile()
    }
    
    func loadFromFile() {
        if let localfilePath = Bundle.main.url(forResource: "instruction", withExtension: ".html") {
            let myRequest = URLRequest(url: localfilePath)
            self.myWebView.load(myRequest)
        }
        
    }
}
