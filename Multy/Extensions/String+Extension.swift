//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

extension String {
    var UTF8CStringPointer: UnsafeMutablePointer<Int8> {
        return UnsafeMutablePointer(mutating: (self as NSString).utf8String!)
    }

    func createBinaryData() -> BinaryData? {
        let pointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        let mbdfh = make_binary_data_from_hex(self.UTF8CStringPointer, pointer)
        
        if mbdfh != nil {
            DataManager.shared.coreLibManager.returnErrorString(opaquePointer: mbdfh!, mask: "make_binary_data_from_hex")
            
            return nil
        } else {
            return pointer.pointee!.pointee
        }
    }
    
    static func generateRandomString() -> String? {
        
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    func toStringWithComma() -> Double {
        if self.isEmpty {
            return 0.0
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.decimalSeparator = ","
        
        if formatter.number(from: self) == nil {
            return 0
        } else {
            return formatter.number(from: self)!.doubleValue
        }
    }
    
    func isValidCryptoAddress() -> Bool {
        //for now: bitcoin
//        let pattern = "^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$"//for bitcoin main net
//        let addressPredicate = NSPredicate(format: "SELF MATHES %@", pattern)
//
//        return addressPredicate.evaluate(with: self)
        
        //bitcoin testnet
        return self.count < 36 && self.count > 25
    }
}
