//
//  User.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import Foundation

struct AppUser {
    
    private(set) var firstName: String
    private(set) var lastName: String
    private(set) var email: String?
    private(set) var contactNumber: String
    
    init(firstName: String, lastName: String, email: String?, contactNumber: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.contactNumber = contactNumber
    }
}
