//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class SendAmountPresenter: NSObject {
    var sendAmountVC: SendAmountViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
            blockedAmount = transactionDTO.choosenWallet!.blockedAmount
            availableSumInCrypto = transactionDTO.choosenWallet!.availableAmount
            availableSumInFiat = availableSumInCrypto * exchangeCourse
            
            if transactionDTO.sendAmount != nil {
                sumInCrypto = transactionDTO.sendAmountString!.convertCryptoAmountStringToMinimalUnits(in: BLOCKCHAIN_BITCOIN)
            }
            transactionObj = transactionDTO.transaction!.transactionRLM
            cryptoName = transactionDTO.blockchainType!.shortName
        }
    }
    var account = DataManager.shared.realmManager.account
    var blockedAmount = BigInt("0")

    var availableSumInCrypto = BigInt("0")
    var availableSumInFiat = BigInt("0")
    
    var transactionObj: TransactionRLM?
    var exchangeCourse = Double(0.0)
    
    var sumInCrypto = BigInt("0")
    var sumInFiat = BigInt("0")
    
    var fiatName = "USD"
    var cryptoName = "BTC"
    
    var isCrypto = true
    var isMaxEntered = false
    
    var maxLengthForSum = 12
    
    var sumInNextBtn = BigInt("0")
    var maxAllowedToSpend = BigInt("0")
    var cryptoMaxSumWithFeeAndDonate = BigInt("0")
    
    var rawTransaction = String()
    var rawTransactionEstimation = 0.0
    var rawTransactionBigIntEstimation = BigInt.zero()
    
//    var customFee : UInt64?
    
    //for creating transaction
    var binaryData : BinaryData?
    var addressData : Dictionary<String, Any>?
    
    func getData() {
        self.createPreliminaryData()
    }
    
    func createPreliminaryData() {
        let core = DataManager.shared.coreLibManager
        let wallet = transactionDTO.choosenWallet!
        binaryData = account!.binaryDataString.createBinaryData()!
        
        addressData = core.createAddress(blockchain:    transactionDTO.blockchainType!,
                                         walletID:      wallet.walletID.uint32Value,
                                         addressID:     UInt32(wallet.addresses.count),
                                         binaryData:    &binaryData!)
    }
    
    func estimateTransaction() -> Bool {
        if transactionDTO.blockchainType!.blockchain != BLOCKCHAIN_BITCOIN {
            print("\n\n\nnot right screen\n\n\n")
        }
        
        let trData = DataManager.shared.coreLibManager.createTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                                                         sendAddress: transactionDTO.sendAddress!,
                                                                         sendAmountString: sumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN),
                                                                         feePerByteAmount: "\(transactionDTO.transaction!.customFee!)",
            isDonationExists: transactionDTO.transaction!.donationDTO!.sumInCrypto != 0.0,
            donationAmount: transactionDTO.transaction!.donationDTO!.sumInCrypto!.fixedFraction(digits: 8),
            isPayCommission: self.sendAmountVC!.commissionSwitch.isOn,
            wallet: transactionDTO.choosenWallet!,
            binaryData: &binaryData!,
            inputs: transactionDTO.choosenWallet!.addresses)
        
        rawTransaction = trData.0
        rawTransactionEstimation = trData.1
        rawTransactionBigIntEstimation = BigInt(trData.2)

        
        return trData.1 >= 0
    }
    
    func setAmountFromQr() {
        if self.sumInCrypto != 0.0 {
            self.sendAmountVC?.amountTF.text = self.sumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
            self.sendAmountVC?.topSumLbl.text = self.sumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
            self.sendAmountVC?.btnSumLbl.text = self.sumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
        }
    }
    
    func cryptoToUsd() {
//        self.sumInFiat = Double(self.sendAmountVC!.topSumLbl.text!.replacingOccurrences(of: ",", with: "."))! * transactionDTO.choosenWallet!.exchangeCourse
        sendAmountVC?.bottomSumLbl.text = sumInFiat.fiatValueString(for: BLOCKCHAIN_BITCOIN)
    }
    
    func usdToCrypto() {
        sumInCrypto = sumInFiat / exchangeCourse
        if sumInCrypto > availableSumInCrypto {
            sendAmountVC?.bottomSumLbl.text = availableSumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
        } else {
            sendAmountVC?.bottomSumLbl.text = sumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
        }
    }
    
    func setSpendableAmountText() {
        if isCrypto {
            sendAmountVC?.spendableSumAndCurrencyLbl.text = availableSumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN) + " " + cryptoName
        } else {
            sendAmountVC?.spendableSumAndCurrencyLbl.text = availableSumInFiat.fiatValueString(for: BLOCKCHAIN_BITCOIN) + " " + fiatName
        }
    }
    
    func getNextBtnSum() -> BigInt {
        
        if sumInCrypto == Int64(0) {
            return sumInCrypto
        }
        
        let estimate = estimateTransaction()
        
        if estimate == false {
            //FIXME: localize errors from core lib
            let message = rawTransaction
            let alert = UIAlertController(title: sendAmountVC!.localize(string: Constants.errorString), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in }))
            sendAmountVC!.present(alert, animated: true, completion: nil)
            
            sendAmountVC?.amountTF.text = "0"
            sendAmountVC?.topSumLbl.text = "0"
            saveTfValue()
            checkMaxEntered()
            sendAmountVC?.setSumInNextBtn()
            sendAmountVC?.sendAnalyticsEvent(screenName: "\(screenSendAmountWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: transactionErr)
            return BigInt("-1")
        }
        
        transactionObj?.sumInCrypto = rawTransactionEstimation
        transactionObj?.sumInFiat = rawTransactionEstimation * exchangeCourse
        
        let fiatEstimation = rawTransactionBigIntEstimation ?? BigInt.zero() * exchangeCourse
        
        switch isCrypto {
        case true:
            if sendAmountVC!.commissionSwitch.isOn {
                if transactionDTO.transaction?.donationDTO != nil {
                    let donationBigIntValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                    sumInNextBtn = sumInCrypto + rawTransactionBigIntEstimation + donationBigIntValue
                } else {
                    sumInNextBtn = sumInCrypto + rawTransactionBigIntEstimation
                }
            } else {  //pay for commision off
                sumInNextBtn = sumInCrypto
            }
            
            if sumInNextBtn > availableSumInCrypto {
                sumInNextBtn = availableSumInCrypto
            }
            
            return sumInNextBtn
        case false:
            if sendAmountVC!.commissionSwitch.isOn {
                if transactionDTO.transaction!.donationDTO != nil {
                    let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                    let donationFiatValue = donationCryptoValue * exchangeCourse
                    
                    sumInNextBtn = sumInFiat + fiatEstimation + donationFiatValue
                } else {
                    sumInNextBtn = sumInFiat + transactionObj!.sumInFiat
                }
            } else {  //pay for commision off
                sumInNextBtn = sumInFiat
            }
            
            if sumInNextBtn > availableSumInFiat {
                sumInNextBtn = availableSumInFiat
            }
            
            return self.sumInNextBtn
        }
    }
    
    func setMaxAllowed() {
        switch isCrypto {
        case true:
            if sendAmountVC!.commissionSwitch.isOn {
                if transactionDTO.transaction!.donationDTO != nil {
                    let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                    
                    maxAllowedToSpend = availableSumInCrypto - rawTransactionBigIntEstimation - donationCryptoValue
                } else {
                    maxAllowedToSpend = availableSumInCrypto - rawTransactionBigIntEstimation
                }
            } else {
                maxAllowedToSpend = availableSumInCrypto
            }
        case false:
            let fiatEstimation = rawTransactionBigIntEstimation ?? BigInt.zero() * exchangeCourse
            
            if sendAmountVC!.commissionSwitch.isOn {
                if transactionDTO.transaction!.donationDTO != nil {
                    let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                    let donationFiatValue = donationCryptoValue * exchangeCourse
                    
                    maxAllowedToSpend = availableSumInFiat - fiatEstimation - donationFiatValue
                } else {
                    maxAllowedToSpend = availableSumInFiat - fiatEstimation
                }
            } else {
                maxAllowedToSpend = availableSumInFiat
            }
        }
    }
    
    func saveTfValue() {
        if isCrypto {
            sumInCrypto = sendAmountVC!.topSumLbl.text!.convertCryptoAmountStringToMinimalUnits(in: BLOCKCHAIN_BITCOIN)
            sumInFiat = sumInCrypto * exchangeCourse

            if sumInFiat > availableSumInFiat {
                sendAmountVC?.bottomSumLbl.text = availableSumInFiat.cryptoValueString(for: BLOCKCHAIN_BITCOIN) + " "
            } else {
                sendAmountVC?.bottomSumLbl.text = sumInFiat.fiatValueString(for: BLOCKCHAIN_BITCOIN) + " "
            }
            
            sendAmountVC?.bottomCurrencyLbl.text = fiatName
        } else {
            sumInFiat = BLOCKCHAIN_BITCOIN.multiplyerToMinimalUnits * Double(sendAmountVC!.topSumLbl.text!.stringWithDot)
            sumInCrypto = sumInFiat / exchangeCourse
            
            if sumInCrypto > availableSumInCrypto {
                sendAmountVC?.bottomSumLbl.text = availableSumInCrypto.cryptoValueString(for: BLOCKCHAIN_BITCOIN) + " "
            } else {
                self.sendAmountVC?.bottomSumLbl.text = sumInCrypto.cryptoValueString(for: BLOCKCHAIN_ETHEREUM) + " "
            }
            
            self.sendAmountVC?.bottomCurrencyLbl.text = self.cryptoName
        }
    }
   
    func checkMaxEntered() {
        if isCrypto {
            switch sendAmountVC?.commissionSwitch.isOn {
            case true?:
                if sumInCrypto >= cryptoMaxSumWithFeeAndDonate {
                    isMaxEntered = true
                } else {
                    isMaxEntered = false
                }
            case false?:
                if sumInCrypto >= availableSumInCrypto  {
                    isMaxEntered = true
                } else {
                    isMaxEntered = false
                }
            case .none:
                return
            }
        } else {
            switch sendAmountVC?.commissionSwitch.isOn {
            case true?:
                if sumInFiat >= cryptoMaxSumWithFeeAndDonate {
                    isMaxEntered = true
                } else {
                    isMaxEntered = false
                }
            case false?:
                if sumInFiat >= availableSumInFiat  {
                    isMaxEntered = true
                } else {
                    isMaxEntered = false
                }
            case .none:
                return
            }
        }
    }
    
    func makeMaxSumWithFeeAndDonate() {
        if isCrypto {
            if transactionDTO.transaction!.donationDTO != nil {
                let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                
                cryptoMaxSumWithFeeAndDonate = availableSumInCrypto - rawTransactionBigIntEstimation - donationCryptoValue
            } else {
                cryptoMaxSumWithFeeAndDonate = availableSumInCrypto - rawTransactionBigIntEstimation
            }
        } else {
            let fiatEstimation = rawTransactionBigIntEstimation * exchangeCourse
            
            if transactionDTO.transaction!.donationDTO != nil {
                let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                let donationFiatValue = donationCryptoValue * exchangeCourse
                
                cryptoMaxSumWithFeeAndDonate = availableSumInFiat - fiatEstimation - donationFiatValue
            } else {
                cryptoMaxSumWithFeeAndDonate = availableSumInFiat - fiatEstimation
            }
        }
    }
    
    func messageForAlert() -> String {
        var message = ""
        switch isCrypto {
        case true:
            if transactionDTO.transaction!.donationDTO != nil {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeAndDonationString) +
                    "\((self.transactionObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)" +
                    sendAmountVC!.localize(string: Constants.andDonationString) +
                "\((transactionDTO.transaction!.donationDTO?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)"
            } else {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeString) + "\((self.transactionObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)"
            }
        case false:
            if transactionDTO.transaction!.donationDTO != nil {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeAndDonationString) +
                "\((self.transactionObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)" +
                sendAmountVC!.localize(string: Constants.andDonationString) +
                "\((transactionDTO.transaction!.donationDTO?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)"
            } else {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeString) + "\((self.transactionObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)"
            }
        }
        
        return message
    }
    
    deinit {
        let accountPointer = addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>
        free_account(accountPointer.pointee)
        accountPointer.deallocate()
    }
}
