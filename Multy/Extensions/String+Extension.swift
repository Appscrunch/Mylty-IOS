//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import UIKit

extension Character {
    var asciiCode: UInt32 {
        get {
            let scalars = unicodeScalars
            
            return scalars[scalars.startIndex].value
        }
    }
}

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    var UTF8CStringPointer: UnsafeMutablePointer<Int8> {
        return UnsafeMutablePointer(mutating: (self as NSString).utf8String!)
    }
    
    var stringWithDot: String {
        get {
            return  self.replacingOccurrences(of: ",", with: ".")
        }
    }
    
    var doubleValue: Double {
        get {
            return Double(self.stringWithDot)!
        }
    }
    
    //temporaty usage // FIXME: address blockchain
    var addressBlockchainValue: Blockchain {
        get {
            if hasPrefix("0x") {
                return BLOCKCHAIN_ETHEREUM
            } else {
                return BLOCKCHAIN_BITCOIN
            }
        }
    }

    func createBinaryData() -> BinaryData? {
        let pointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        defer {
//            free_binarydata(pointer.pointee)
            pointer.deallocate(capacity: 1)
        }
        let mbdfh = make_binary_data_from_hex(self.UTF8CStringPointer, pointer)
        
        if mbdfh != nil {
            _ = DataManager.shared.coreLibManager.errorString(from: mbdfh!, mask: "make_binary_data_from_hex")
            
            return nil
        } else {
            return pointer.pointee!.pointee
        }
    }
    
    func convertStringWithCommaToDouble() -> Double {
        if self.isEmpty {
            return 0.0
        }
        
        if self == "," || self == "." {
            return 0.0
        }
        
        //        let formatter = NumberFormatter()
        //        formatter.numberStyle = NumberFormatter.Style.decimal
        //        formatter.decimalSeparator = ","
        //        formatter.maximumFractionDigits = 8
        
        //        if formatter.number(from: self) == nil {
        //            return 0
        //        } else {
        //            return formatter.number(from: self)!.doubleValue
        //        }
        return Double(self.replacingOccurrences(of: ",", with: "."))!
    }
    
    private mutating func stringWithoutZeroesFromStart() -> String {
        var modifiedString = self
        while modifiedString.hasPrefix("0") && modifiedString.count > 1 {
            modifiedString.remove(at: self.startIndex)
        }
        
        return modifiedString
    }
    
    private mutating func append(delimeter: Character, atIndexFromEnd: Int) {
        self.insert(delimeter, at: self.index(self.endIndex, offsetBy: -atIndexFromEnd))
    }
    
    func toStringWithZeroes(precision: Int) -> String {
        let string = self.replacingOccurrences(of: ".", with: ",")
        let components = string.components(separatedBy: CharacterSet.init(charactersIn: "\(defaultDelimeter)"))
        
        if precision < 1 {
            if self.isEmpty {
                return "0"
            }
            
            return components.first!
        }
        
        //two delimeters - wrong case
        precondition(components.count < 3, "---===Wrong string===---")
        
        if components.count == 1 {
            return self + String(repeating: "0", count: precision)
        } else {
            let firstComponent = components.first!
            let secondComponent = components.last!
            
            var finalString = String()
            
            switch secondComponent.count {
            case 0..<precision:
                finalString = firstComponent + secondComponent + String(repeating: "0", count: precision - secondComponent.count)
            case precision:
                finalString = firstComponent + secondComponent
            case precision...LONG_MAX:
                let index = secondComponent.index(secondComponent.startIndex, offsetBy: precision)
                finalString = firstComponent + secondComponent[..<index]
            default:
                return "0"
            }
            
            return finalString.stringWithoutZeroesFromStart()
        }
    }
    
    func appendDelimeter(at index: Int) -> String {
        if index < 1 {
            return self
        }
        
        var modifiedString = self
        
        if self.count > index {
            modifiedString.append(delimeter: defaultDelimeter, atIndexFromEnd: index)
        } else {
            let zeroesString = String(repeating: "0", count: index - self.count + 1)
            modifiedString = zeroesString + modifiedString
            modifiedString.append(delimeter: defaultDelimeter, atIndexFromEnd: index)
        }
        
        modifiedString.deletetTrailingZeroes()
        
        return modifiedString
    }
    
    mutating func deletetTrailingZeroes() {
        let stringParts = self.components(separatedBy: "\(defaultDelimeter)")
        var fractionString = stringParts[1]
        
        while fractionString.last == "0" && fractionString.count > 1 {
            fractionString.removeLast()
        }
        
        self = stringParts[0] + "\(defaultDelimeter)" + fractionString
    }
    
    func convertCryptoAmountStringToMinimalUnits(in blockchain: Blockchain) -> BigInt {
//        return blockchain.multiplyerToMinimalUnits * (Double(self.stringWithDot) ?? 0)
        var stringAmount = toStringWithZeroes(precision: blockchain.maxPrecision).replacingOccurrences(of: ".", with: "")
        stringAmount = stringAmount.replacingOccurrences(of: ",", with: "")
        
        return BigInt(stringAmount.stringWithoutZeroesFromStart())
    }
    
    func convertToSatoshiAmountString() -> String {
        return self.toStringWithZeroes(precision: 8)
    }
    
    func convertToFiatAmountString() -> String {
        return self.toStringWithZeroes(precision: 2)
    }
    
    func fiatValueString(for blockchainType: BlockchainType) -> String {
        let exchangeCourse = DataManager.shared.makeExchangeFor(blockchainType: blockchainType)
        
        return (convertCryptoAmountStringToMinimalUnits(in: blockchainType.blockchain) * exchangeCourse).fiatValueString(for: blockchainType.blockchain)
    }
    
    func showString(_ precision: Int) -> String {
        let components = self.components(separatedBy: CharacterSet.init(charactersIn: "\(defaultDelimeter)"))
        
        if precision < 1 {
            if isEmpty {
                return "0"
            }
            
            return components.first!
        }
        
        //two delimeters - wrong case
        precondition(components.count < 3, "---===Wrong string===---")
        
        if components.count == 1 {
            return self
        } else {
            let firstComponent = components.first!
            let secondComponent = components.last!
            
            var finalString = String()
            
            switch secondComponent.count {
            case 0...precision:
                finalString = firstComponent + "\(defaultDelimeter)" + secondComponent
            case precision + 1...LONG_MAX:
                let index = secondComponent.index(secondComponent.startIndex, offsetBy: precision)
                finalString = firstComponent + "\(defaultDelimeter)" + secondComponent[..<index]
            default:
                return "0"
            }
            
            return finalString
        }
    }

    func toDateTime() -> NSDate {
        let dateFromString = Date.blockDateFormatter().date(from: self)! as NSDate
        
        return dateFromString
    }
        
    func getDonationAddress(blockchainType: BlockchainType) -> String? {
        if blockchainType.blockchain.rawValue != 0 {
            return nil
        } else {
            if blockchainType.net_type == 0 {
                let donationArray = DataManager.shared.getBTCDonationAddressesFromUserDerfaults().values
                
                for address in donationArray {
                    if self.contains(address) {
                        return address
                    }
                }
                
                return nil
            } else if blockchainType.net_type == 1 {
                let donationAddress = Constants.DataManager.btcTestnetDonationAddress
                
                return self.contains(donationAddress) ? donationAddress : nil
            } else {
                return nil
            }
        }
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
