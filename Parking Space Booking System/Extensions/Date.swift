//
//  Date.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import Foundation

extension Date {
    static func currentDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
