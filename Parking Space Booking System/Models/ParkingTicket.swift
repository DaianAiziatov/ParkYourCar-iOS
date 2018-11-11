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
            default: return ""
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
            default: return ""
            }
        }
    }
    
    func loadParkingTickets() {
        
    }
}
