//
//  Manufacturer.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct Manufacturer {
    
    private(set) var name: String
    private(set) var models = [String]()
    
    init(name: String, models: [String]) {
        self.name = name
        self.models = models
    }
    
}
