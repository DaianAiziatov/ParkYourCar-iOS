//
//  UIImageView.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import UIKit

var imagesCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode) {
        self.contentMode = mode
        if let cachedImage = imagesCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                imagesCache.setObject(image, forKey: url.absoluteString as NSString)
                activityIndicator.stopAnimating()
            }
            }.resume()
    }
    
}

