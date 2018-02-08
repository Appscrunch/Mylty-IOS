//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class TopIndexRLM: Object {
    @objc dynamic var currencyID = NSNumber(value: 0)
    @objc dynamic var topIndex = NSNumber(value: 0)
    
    public class func initWithArray(indexesArray: NSArray) -> List<TopIndexRLM> {
        let topIndexes = List<TopIndexRLM>()
        
        for index in indexesArray {
            let topIndex = TopIndexRLM.initWithInfo(indexDict: index as! NSDictionary)
            topIndexes.append(topIndex)
        }
        
        return topIndexes
    }
    
    public class func createDefaultIndex(currencyID: NSNumber, topIndex: NSNumber) -> TopIndexRLM {
        let newTopIndex = TopIndexRLM()
        newTopIndex.currencyID = currencyID
        newTopIndex.topIndex = topIndex
        
        return newTopIndex
    }
    
    public class func initWithInfo(indexDict: NSDictionary) -> TopIndexRLM {
        let topIndexRLM = TopIndexRLM()
        
        if let currencyID = indexDict["currencyid"] {
            topIndexRLM.currencyID = NSNumber(value: currencyID as! UInt32)
        }
        
        if let index = indexDict["topindex"] as? UInt32 {
            topIndexRLM.topIndex = NSNumber(value: index)
        }
        
        return topIndexRLM
    }
}

class AccountRLM: Object {
    @objc dynamic var seedPhrase = String() {
        didSet {
            if seedPhrase != "" {
                self.backupSeedPhrase = seedPhrase
            }
        }
    }
    @objc dynamic var backupSeedPhrase = String()
    @objc dynamic var binaryDataString = String()
    
    @objc dynamic var userID = String()
    @objc dynamic var deviceID = String()
    @objc dynamic var deviceType = 1
    @objc dynamic var pushToken = String()
    
    @objc dynamic var expireDateString = String()
    @objc dynamic var token = String()
    @objc dynamic var id: NSNumber = 1
    
    var topIndexes = List<TopIndexRLM>()
    
    @objc dynamic var walletCount: NSNumber = 0
    var wallets = List<UserWalletRLM>() {
        didSet {
            walletCount = NSNumber(value: wallets.count)
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
