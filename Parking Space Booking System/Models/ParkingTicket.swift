//
//  ParkingTicket.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 11/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import Foundation

struct ParkingTicket {
    
    var userEmail: String
    var carPlate: String
    var carManufacturer: String
    var carModel: String
    var carColor: String
    var timing: Timing
    var date: Date
    var slotNumber: String
    var spotNumber: String
    var paymentMethod: PaymentMethod
    var paymentAmount: Double
    
    enum Timing: String {
        case halfAHour = "30 mins"
        case oneHour = "1 hour"
        case twoHour = "2 hors"
        case threeHour = "3 hours"
        case dayEnds = "Day Ends"
    }
    
    enum PaymentMethod: String {
        case visaDebit = "Visa Debit"
        case visaCredit = "Visa Credit"
        case masterCard = "Mastercard"
        case paypal = "PayPal"
        case aliPay = "Ali Pay"
        case wechatPay = "WeChat Pay"
    }
    
    func loadParkingTickets() {
        
    }
}
