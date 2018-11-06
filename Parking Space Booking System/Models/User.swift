//
//  User.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct User {
    
    var userId: Int
    var name: String
    var sername: String
    var email: String
    var password: String
    var contactNumber: String
    var cars: [Car]
    var tickets: [Ticket]
    
}
