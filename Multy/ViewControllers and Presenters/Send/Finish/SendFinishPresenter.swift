//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendFinishPresenter: NSObject {

    var sendFinishVC: SendFinishViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            cryptoName = transactionDTO.blockchainType.shortName
        }
    }
    
    var account = DataManager.shared.realmManager.account
    
    var selectedSpeedIndex: Int?
    
    var sumInCrypto: Double?
    var sumInFiat: Double?
    var cryptoName: String?
    var fiatName: String = "USD"//MARK: get from settings
    
    var isCrypto = true
    
    func makeEndSum() {
        switch self.isCrypto {
        case true:
            self.sumInCrypto = transactionDTO.transaction?.endSum
            self.sumInFiat = self.sumInCrypto! * transactionDTO.choosenWallet!.exchangeCourse
        case false:
            self.sumInFiat = transactionDTO.transaction?.endSum
            self.sumInCrypto = self.sumInFiat!
        }
    }
    
    func makeFrameForSlider() -> CGRect {
        var y = self.sendFinishVC!.view.frame.height - 64
        if screenHeight == heightOfX {
            y = 705.0
        }
        let frame = CGRect(x: 0, y: y, width: screenWidth, height: 64.0)
        
        return frame
    }
}
