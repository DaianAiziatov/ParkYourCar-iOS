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
    
    let js = "javascript:function listenForLoad(){var url = window.location.pathname;var isLoaded = false;var loadReq;if (url === '/' && !isLoaded) {loadReq = window.requestAnimationFrame(listenForLoad);} else {isLoaded = true;var content = document.getElementsByClassName('container info-page');for(var i = 0; i < content.length; i++){content[i].style.top = '0px';}var header = document.getElementsByClassName('header');while(header.length > 0){header[0].parentNode.removeChild(header[0]);}var footer = document.getElementById('footer'); footer.parentNode.removeChild(footer);while(footer.length > 0){footer[0].parentNode.removeChild(footer[0]);}return;}}listenForLoad();"

    var webView:WKWebView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFromFile()
    }
    
    func loadFromFile() {
        let config = WKWebViewConfiguration()
        
         // Inject custom JS
        let contentController = WKUserContentController()
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        config.userContentController = contentController
        
        // Enable JS
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        // Load page
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView!.load(URLRequest(url: URL(string: "https://www.planyo.com/tutorial-prices.php")!))
        
        self.view.addSubview(webView!)    }
}
