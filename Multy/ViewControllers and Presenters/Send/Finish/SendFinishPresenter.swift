//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendFinishPresenter: NSObject {

    var sendFinishVC: SendFinishViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            cryptoName = transactionDTO.blockchainType!.shortName
        }
    }
    
    var account = DataManager.shared.realmManager.account
    
    var selectedSpeedIndex: Int?
    
    var sumInCrypto: Double?
    var sumInCryptoString = String()
    var sumInFiat: Double?
    var sumInFiatString = String()
    
    var feeAmountInCryptoString = String()
    var feeAmountInFiatString = String()
    
    var cryptoName = "BTC"
    var fiatName = "USD" // MARK: get from settings
    
    var isCrypto = true
    
    func makeEndSum() {
        switch isCrypto {
        case true:
            if transactionDTO.choosenWallet!.blockchainType.blockchain == BLOCKCHAIN_BITCOIN {
                sumInCrypto = transactionDTO.sendAmountString?.stringWithDot.doubleValue
                sumInCryptoString = sumInCrypto!.fixedFraction(digits: 8)
                sumInFiat = sumInCrypto! * transactionDTO.choosenWallet!.exchangeCourse
                sumInFiatString = sumInFiat!.fixedFraction(digits: 2)
                
                feeAmountInCryptoString = (transactionDTO.transaction?.transactionRLM?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)
                feeAmountInFiatString = (transactionDTO.transaction?.transactionRLM?.sumInFiat ?? 0.0).fixedFraction(digits: 2)
            } else if transactionDTO.choosenWallet!.blockchainType.blockchain == BLOCKCHAIN_ETHEREUM {
                sumInCryptoString = transactionDTO.sendAmountString!
                sumInFiatString = (transactionDTO.transaction!.endSumBigInt! * transactionDTO.choosenWallet!.exchangeCourse).fiatValueString(for: BLOCKCHAIN_ETHEREUM)
                
                let feeAmount = transactionDTO.transaction!.feeAmount
                let feeAmountInWei = feeAmount * transactionDTO.choosenWallet!.exchangeCourse
                feeAmountInCryptoString = feeAmount.cryptoValueString(for: BLOCKCHAIN_ETHEREUM)
                feeAmountInFiatString = feeAmountInWei.fiatValueString(for: BLOCKCHAIN_ETHEREUM)
            }
        case false:
            self.sumInFiat = transactionDTO.transaction?.endSum
            self.sumInCrypto = self.sumInFiat!
        }
    }
    
    func makeFrameForSlider() -> CGRect {
        let y = self.sendFinishVC!.scrollView.contentSize.height - 64    // 64 - height of send btn
        let frame = CGRect(x: 0, y: y, width: screenWidth, height: 64.0)
        
        return frame
    }
}
