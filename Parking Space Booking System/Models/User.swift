//
//  User.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 05/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation


struct User {
    
    //TODO: is user still neccessary? or we should transform it to singleton(?)
    var userId: Int
    var name: String
    var surname: String
    var email: String
    var password: String
    var contactNumber: String
    var cars = [Car]()
    var tickets = [Ticket]()
    
    static var allUsers = loadUsers()
    
    init(name: String, surname: String, email: String, password: String, contactNumber: String, cars: [Car]) {
        self.userId = User.getUniqIdentifier()
        self.name = name
        self.surname = surname
        self.email = email
        self.password = password
        self.contactNumber = contactNumber
        self.cars = cars
    }
    
    static func loadUsers() -> [User] {
        var allUsers = [User]()
        allUsers.append(User(name: "aaa", surname: "bbb", email: "a@b.com", password: "1234", contactNumber: "123", cars: [Car(manufacturerName: "Mazda", modelName: "RX8", plateNumber: "sbckbe", color: "black")]))
        allUsers.append(User(name: "xxx", surname: "yyy", email: "x@y.com", password: "1234", contactNumber: "123", cars: [Car(manufacturerName: "BMW", modelName: "X6", plateNumber: "sbckbe", color: "red")]))
        return allUsers
    }
    
    private static var identifierFactory = 0;
    
    private static func getUniqIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
}
