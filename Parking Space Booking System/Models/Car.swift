//
//  Car.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct Car {
    
    private(set) var carId: Int
    private(set) var manufacturer: String
    private(set) var model: String?
    private(set) var plateNumber: String
    private(set) var color: String
    
    static var manufacturers = Manufacturer.loadManufacturers()
    
    init(manufacturerName: String, modelName: String, plateNumber: String, color: String) {
        self.carId = Car.getUniqIdentifier()
        self.manufacturer = manufacturerName
        self.model = modelName
        self.plateNumber = plateNumber
        self.color = color
    }
    
    private static var identifierFactory = 0;
    
    private static func getUniqIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
}
