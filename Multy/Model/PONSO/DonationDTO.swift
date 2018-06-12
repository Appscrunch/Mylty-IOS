//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

class DonationDTO: NSObject {
    var sumInCrypto: Double? = 0.0
    var sumInCryptoBigInt: BigInt?
    var cryptoName = String()
    var sumInFiat: Double? = 0.0
    var fiatName = String()
}
