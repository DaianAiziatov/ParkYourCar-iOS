//
//  Car.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct Car {
    
    private var carId: Int
    private var manufacturer: Manufacturer
    private var model: String?
    private var plateNumber: String
    private var color: String
    
    static var manufacturers = Manufacturer.loadManufacturers()
    
    init(manufacturerName: String, modelName: String, plateNumber: String, color: String) {
        self.carId = Car.getUniqIdentifier()
        self.manufacturer = Car.manufacturers[manufacturerName]!
        for model in self.manufacturer.models {
            if model == modelName {
                self.model = model
                break
            } else {
                self.model = nil
            }
        }
        self.plateNumber = plateNumber
        self.color = color
    }
    
    private static var identifierFactory = 0;
    
    private static func getUniqIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
}
