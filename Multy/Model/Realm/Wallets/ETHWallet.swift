//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class ETHWallet: Object {
    @objc dynamic var nonce = NSNumber(value: 0)
    @objc dynamic var balance = String()
    @objc dynamic var pendingWeiAmountString = "0"
    
    var allBalance: BigInt {
        get {
            return BigInt(balance.isEmpty ? "0" : balance) + pendingBalance
        }
    }
    
    var availableBalance: BigInt {
        get {
            return BigInt(balance)
        }
    }
    
    var pendingBalance: BigInt {
        get {
            return BigInt(pendingWeiAmountString)
        }
    }
    
    var isThereAvailableBalance: Bool {
        get {
            return availableBalance > Int64(0)
        }
    }
    
    var pendingETHAmountString: String {
        get {
            return pendingWeiAmountString.appendDelimeter(at: 18)
        }
    }
}
