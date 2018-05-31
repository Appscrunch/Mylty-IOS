//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class TransactionRLM: NSObject {
    @objc dynamic var speedName = String()
    @objc dynamic var speedTimeString = String()  //∙ 10 minutes  ∙ 2 weeks
    @objc dynamic var sumInCrypto: Double = 0.0
    @objc dynamic var sumInCryptoBigInt = BigInt("0")
    @objc dynamic var sumInFiat: Double = 0.0
    @objc dynamic var cryptoName = String()
    @objc dynamic var fiatName = String()
    @objc dynamic var fiatSymbol = String()
    @objc dynamic var numberOfBlocks = Int()
}
