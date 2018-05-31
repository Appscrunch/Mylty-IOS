//
//  Wireless+Extension.swift
//  Multy
//
//  Created by Artyom Alekseev on 31.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import Foundation

extension String {
    var convertToImageIndex: UInt32 {
        let sum = map{ char in char.asciiCode }.reduce(0, +)
        
        return sum % 20
    }
    
    var convertToUserCode: String? {
        var result = String()
        result = String(self[..<self.index(self.startIndex, offsetBy: 4)])
        let resultHex = result.unicodeScalars.filter { $0.isASCII }.map { String(format: "%X", $0.value) }.joined()
        if resultHex.count == 8 {
            return resultHex.uppercased()
        } else {
            return nil
        }
    }
}
