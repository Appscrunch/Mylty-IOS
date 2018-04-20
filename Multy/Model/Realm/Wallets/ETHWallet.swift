//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class ETHWallet: Object {
    @objc dynamic var nonce = NSNumber(value: 0)
    @objc dynamic var balance = String()
    @objc dynamic var pendingWeiAmountString = "0"
    
    var pendingETHAmountString: String {
        get {
            return pendingWeiAmountString.appendDelimeter(at: 18)
        }
    }
}
