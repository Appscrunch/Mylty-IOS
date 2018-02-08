//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendFinishPresenter: NSObject {

    var sendFinishVC: SendFinishViewController?
    
    var rawTransaction: String?
    var account: AccountRLM?
    
    var walletFrom: UserWalletRLM?
    
    var addressToStr: String?
    
    var selectedSpeedIndex: Int?
    
    var sumInCrypto: Double?
    var sumInFiat: Double?
    var cryptoName: String?
    var fiatName: String?
    
    var isCrypto = true
    var endSum = 0.0
    
    var transactionObj: TransactionRLM?
    
    //Example for addressData
    //        ["privateKey": "2bdeccJBhnRiDz5cSaHhxfiAoACGaQzfbZizmK7KNqbvtP4Bmc",
    //         "addressIndex": 0,
    //         "addressPrivateKeyPointer": 0x0000000174456560,
    //         "addressPointer": 0x0000000174289ce0,
    //         "address": "mzNZBhim9XGy66FkdzrehHwdWNgbiTYXCQ",
    //         "walletIndex": 0,
    //         "currencyID": 0,
    //         "publicKey": "NkWaWtGAq2MA2wkQaZ4s66HttE598b3Bqc7CueS9J3ry7zvBLG76us11eTxkpVYH7th1z5SKDP3oNMJxGyZe8zRv"]
    var addressData : Dictionary<String, Any>?
    
    func makeEndSum() {
        switch self.isCrypto {
        case true:
            self.sumInCrypto = self.endSum
            self.sumInFiat = Double(round(100*self.sumInCrypto! * exchangeCourse)/100)
        case false:
            self.sumInFiat = self.endSum
            self.sumInCrypto = Double(round(100000000*self.sumInFiat!)/100000000)
        }
    }
}
