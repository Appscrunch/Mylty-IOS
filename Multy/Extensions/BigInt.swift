//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

enum BigIntOperation {
    case add, subtract, multiply, divide
}

class BigInt: NSObject {
    // main stored value
    var valuePointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
    
    init(_ stringValue: String) {
        super.init()
        
        let mbi = make_big_int(stringValue.UTF8CStringPointer, valuePointer)
        let _ = DataManager.shared.coreLibManager.errorString(from: mbi, mask: "\n\ninit big int\n\n")
    }
    
    var isNonZero: Bool {
        get {
            return self != Int64(0)
        }
    }
    
    var isZero: Bool {
        get {
            return self == Int64(0)
        }
    }
    
    override convenience init() {
        self.init("0")
    }
    
    class func zero() -> BigInt {
        return BigInt("0")
    }
    
    func setBigInt(string: String) {
        let bisv = big_int_set_value(valuePointer.pointee, string.UTF8CStringPointer)
        
        let _ = DataManager.shared.coreLibManager.errorString(from: bisv, mask: "\n\nbig int: set value\n\n")
    }
    
    func cloneBigInt() -> BigInt {
        let newBigInt = BigInt()
        let mbic = make_big_int_clone(self.valuePointer.pointee, newBigInt.valuePointer)
        let _ = DataManager.shared.coreLibManager.errorString(from: mbic, mask: "\n\nbig int: make_big_int_clone\n\n")
        
        return newBigInt
    }
    
    // arithmetic methods
    func modify<T>(with operation: BigIntOperation, by right: T) -> BigInt {
        let newSelf = self.cloneBigInt()
        var error: OpaquePointer?
        
        switch operation {
        case .add:
            if let right = right as? BigInt {
                error = big_int_add(newSelf.valuePointer.pointee, right.valuePointer.pointee)
            } else if let right = right as? Int64 {
                error = big_int_add_int64(newSelf.valuePointer.pointee, right)
            } else if let right = right as? Double {
                error = big_int_add_double(newSelf.valuePointer.pointee, right)
            } else {
                precondition(true, "You are addiing inapropriate types")
            }
        case .subtract:
            if let right = right as? BigInt {
                error = big_int_sub(newSelf.valuePointer.pointee, right.valuePointer.pointee)
            } else if let right = right as? Int64 {
                error = big_int_sub_int64(newSelf.valuePointer.pointee, right)
            } else if let right = right as? Double {
                error = big_int_sub_double(newSelf.valuePointer.pointee, right)
            } else {
                precondition(true, "You are subtracting inapropriate types")
            }
        case .multiply:
            if let right = right as? BigInt {
                error  = big_int_mul(newSelf.valuePointer.pointee, right.valuePointer.pointee)
            } else if let right = right as? Int64 {
                error = big_int_mul_int64(newSelf.valuePointer.pointee, right)
            } else if let right = right as? Double {
                error = big_int_mul_double(newSelf.valuePointer.pointee, right)
            } else {
                precondition(true, "You are multiplying inapropriate types")
            }
        case .divide:
            if let right = right as? BigInt {
                error  = big_int_div(newSelf.valuePointer.pointee, right.valuePointer.pointee)
            } else if let right = right as? Int64 {
                error = big_int_div_int64 (newSelf.valuePointer.pointee, right)
            } else if let right = right as? Double {
                error = big_int_div_double(newSelf.valuePointer.pointee, right)
            } else {
                precondition(true, "You are dividing inapropriate types")
            }
        }
        
        let _ = DataManager.shared.coreLibManager.errorString(from: error, mask: "\n\nbig int: \(operation)\n\n")
        
        return newSelf
    }
    
    func add<T>(by right: T) -> BigInt {
        return modify(with: .add, by: right)
    }
    
    func subtract<T>(by right: T) -> BigInt {
        return modify(with: .subtract, by: right)
    }
    
    func multiply<T>(by right: T) -> BigInt {
        return modify(with: .multiply, by: right)
    }
    
    func divide<T>(by right: T) -> BigInt {
        return modify(with: .divide, by: right)
    }
    
    static func + <T>(left: BigInt, right: T) -> BigInt {
        return left.add(by: right)
    }
    
    static func - <T>(left: BigInt, right: T) -> BigInt {
        return left.subtract(by: right)
    }
    
    static func * <T>(left: BigInt, right: T) -> BigInt {
        return left.multiply(by: right)
    }
    
    static func / <T>(left: BigInt, right: T) -> BigInt {
        return left.divide(by: right)
    }
    
    // comparing methods
    func compare<T>(to right: T) -> Int32 {
        let boolPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        var bic: OpaquePointer?
        
        if let right = right as? BigInt {
            bic = big_int_cmp(self.valuePointer.pointee, right.valuePointer.pointee, boolPointer)
        } else if let right = right as? Int64 {
            bic = big_int_cmp_int64(self.valuePointer.pointee, right, boolPointer)
        } else if let right = right as? Double {
            bic = big_int_cmp_double(self.valuePointer.pointee, right, boolPointer)
        } else {
            precondition(false, "You are comparing inapropriate types")
        }
        
        let _ = DataManager.shared.coreLibManager.errorString(from: bic, mask: "\n\nbig int: compare BigInt\n\n")
        
        return boolPointer.pointee
    }
    
    static func < <T>(left: BigInt, right: T) -> Bool {
        return left.compare(to: right) < 0
    }
    
    static func <= <T>(left: BigInt, right: T) -> Bool {
        return left.compare(to: right) <= 0
    }
    
    static func > <T>(left: BigInt, right: T) -> Bool {
        return !(left <= right)
    }
    
    static func >= <T>(left: BigInt, right: T) -> Bool {
        return !(left < right)
    }
    
    static func == <T>(left: BigInt, right: T) -> Bool {
        return left.compare(to: right) == 0
    }
    
    static func != <T>(left: BigInt, right: T) -> Bool {
        return left.compare(to: right) != 0
    }
    
    // auxillary methods
    var stringValue: String {
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        defer {
            free_string(amountStringPointer.pointee)
        }
        
        big_int_get_value(valuePointer.pointee, amountStringPointer)
        
        return String(cString: amountStringPointer.pointee!)
    }
    
    func fiatValueString(for blockchain: Blockchain) -> String {
        return (self / blockchain.dividerFromCryptoToFiat).stringValue.appendDelimeter(at: 2)
    }
    
    func cryptoValueString(for blockchain: Blockchain) -> String {
        return stringValue.appendDelimeter(at: blockchain.maxPrecision).showString(8)
    }
    
    deinit {
        free_big_int(valuePointer.pointee)
    }
}
