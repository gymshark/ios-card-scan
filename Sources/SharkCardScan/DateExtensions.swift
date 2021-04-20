//
//  File.swift
//  
//
//  Created by Lee Burrows on 20/04/2021.
//

import Foundation

extension Date {
    var monthsSince2000: Int {
        let dateComponent = Calendar(identifier: .gregorian).dateComponents(in: .current, from: self)
        let year = (dateComponent.year ?? 0) % 100
        let month = (dateComponent.month ?? 1) - 1 // DateComponent.month is 1 to 12
        return 12 * year + month
    }
}
