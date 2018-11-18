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
    
    static func loadManufacturers() -> [String: Manufacturer]{
        var manufacturers = [String: Manufacturer]()
        manufacturers["Mazda"] = Manufacturer(name: "Mazda", models: ["RX7", "RX8"])
        manufacturers["BMW"] = Manufacturer(name: "BMW", models: ["X6", "X8"])
        manufacturers["Renault"] = Manufacturer(name: "Renault", models: ["Megan", "Logan"])
        return manufacturers
    }
    
}
