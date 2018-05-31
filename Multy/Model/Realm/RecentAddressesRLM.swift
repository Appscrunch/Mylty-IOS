//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class RecentAddressesRLM: Object {
    
    @objc dynamic var address = String()
    @objc dynamic var lastActionDate = Date()
    @objc dynamic var name = String()
    @objc dynamic var blockchain = NSNumber(value: 0)
    @objc dynamic var blockchainNetType = NSNumber(value: 0)
    
    
    override class func primaryKey() -> String? {
        return "address"
    }
    
    static func createRecentAddress(blockchainType: BlockchainType, address: String, date: Date) -> RecentAddressesRLM {
        let recentAddress = RecentAddressesRLM()
        recentAddress.address = address
        recentAddress.lastActionDate = date
        recentAddress.blockchain = NSNumber(value: blockchainType.blockchain.rawValue)
        recentAddress.blockchainNetType = NSNumber(value: blockchainType.net_type)
        
        return recentAddress
    }
    
    
}
// Logic
// after successful sendind temporary unconfirmed address become confirmed
// unconfirmed address will be the last - and no more then 1
