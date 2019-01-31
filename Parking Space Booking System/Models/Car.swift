//
//  Car.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct Car {
    
    private(set) var carId: String?
    private(set) var manufacturer: String
    private(set) var model: String?
    private(set) var plateNumber: String
    private(set) var color: String
    
    init(carID: String?, manufacturerName: String, modelName: String, plateNumber: String, color: String) {
        self.carId = carID
        self.manufacturer = manufacturerName
        self.model = modelName
        self.plateNumber = plateNumber
        self.color = color
    }
}
