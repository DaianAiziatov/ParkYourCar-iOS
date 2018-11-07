//
//  Manufacturer.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct Manufacturer {
    
    var manufacturerId: Int
    var name: String
    var logo: String
    var models = [String]()
    
    init(name: String, models: [String]) {
        self.manufacturerId = Manufacturer.getUniqIdentifier()
        self.name = name
        self.logo = "\(name).png"
        self.models = models
    }
    
    private static var identifierFactory = 0;
    
    private static func getUniqIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    static func loadManufacturers() -> [String: Manufacturer]{
        var manufacturers = [String: Manufacturer]()
        manufacturers["Mazda"] = Manufacturer(name: "Mazda", models: ["RX7", "RX8"])
        manufacturers["BMW"] = Manufacturer(name: "BMW", models: ["X6", "X8"])
        manufacturers["Renault"] = Manufacturer(name: "Renault", models: ["Megan", "Logan"])
        return manufacturers
    }
    
}
