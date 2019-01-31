//
//  Result.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 28/01/2019.
//  Copyright © 2019 Lambton. All rights reserved.
//

import Foundation

enum Result<T, U: Error> {
    case success(T)
    case failure(U)
}
