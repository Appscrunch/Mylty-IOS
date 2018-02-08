//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

extension Double {
    func fixedFraction(digits: Int) -> String {        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.decimalSeparator = ","
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = digits
        
        return formatter.string(from: NSNumber(floatLiteral: self))!
    }
}
