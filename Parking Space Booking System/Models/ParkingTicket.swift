//
//  ParkingTicket.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 11/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation
import Firebase

struct ParkingTicket {
    
    private(set) var userEmail: String
    private(set) var carPlate: String
    private(set) var carManufacturer: String
    private(set) var carModel: String
    private(set) var carColor: String
    private(set) var timing: Timing
    private(set) var date: Date
    private(set) var slotNumber: String
    private(set) var spotNumber: String
    private(set) var paymentMethod: PaymentMethod
    private(set) var paymentAmount: Double
    
    init(userEmail: String, carPlate: String, carManufacturer: String, carModel: String, carColor: String, timing: String, date: String, slotNumber: String, spotNumber: String, paymentMethod: String, total: Double) {
        self.userEmail = userEmail
        self.carPlate = carPlate
        self.carManufacturer = carManufacturer
        self.carModel = carModel
        self.carColor = carColor
        switch timing {
        case "30 mins": self.timing = Timing.halfAHour
        case "1 hour": self.timing = Timing.oneHour
        case "2 hours": self.timing = Timing.twoHour
        case "3 hours": self.timing = Timing.threeHour
        case "Day Ends": self.timing = Timing.dayEnds
        default: self.timing = Timing.halfAHour
        }
        //TODO: Error handling
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = dateFormatter.date(from: date)!
        self.slotNumber = slotNumber
        self.spotNumber = spotNumber
        self.paymentMethod = PaymentMethod.visaDebit //default
        for payment in PaymentMethod.allCases {
            if paymentMethod == payment.description {
                self.paymentMethod = payment
                break
            }
        }
        self.paymentAmount = total
    }
    
    init(userEmail: String, car: Car, timing: String, date: String, slotNumber: String, spotNumber: String, paymentMethod: String, total: Double) {
        self.userEmail = userEmail
        self.carPlate = car.plateNumber
        self.carManufacturer = car.manufacturer
        self.carModel = car.model!
        self.carColor = car.color
        switch timing {
        case "30 mins": self.timing = Timing.halfAHour
        case "1 hour": self.timing = Timing.oneHour
        case "2 hours": self.timing = Timing.twoHour
        case "3 hours": self.timing = Timing.threeHour
        case "Day Ends": self.timing = Timing.dayEnds
        default: self.timing = Timing.halfAHour
        }
        //TODO: Error handling
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.date = dateFormatter.date(from: date)!
        self.slotNumber = slotNumber
        self.spotNumber = spotNumber
        self.paymentMethod = PaymentMethod.visaDebit //default
        for payment in PaymentMethod.allCases {
            if paymentMethod == payment.description {
                self.paymentMethod = payment
                break
            }
        }
        self.paymentAmount = total
    }
    
    enum Timing: Int, CaseIterable {
        case halfAHour = 0
        case oneHour = 1
        case twoHour = 2
        case threeHour = 3
        case dayEnds = 4
        
        var description: String {
            switch self {
            case .halfAHour: return "30 mins"
            case .oneHour   : return "1 hour"
            case .twoHour  : return "2 hours"
            case .threeHour : return "3 hours"
            case .dayEnds: return "Day Ends"
            }
        }
    }
    
    enum PaymentMethod: Int, CaseIterable {
        case visaDebit = 0
        case visaCredit = 1
        case masterCard = 2
        case paypal = 3
        case aliPay = 4
        case wechatPay = 5
        
        var description: String {
            switch self {
            case .visaDebit: return "Visa Debit"
            case .visaCredit   : return "Visa Credit"
            case .masterCard  : return "Mastercard"
            case .paypal : return "PayPal"
            case .aliPay: return "Ali Pay"
            case .wechatPay: return "WeChat Pay"
            }
        }
    }
    
    
}
