//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias CreateTransactionDelegate = SendAmountEthPresenter

class SendAmountEthPresenter: NSObject {
    var sendAmountVC: SendAmountEthViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            blockedAmount = transactionDTO.choosenWallet!.blockedAmount
            availableSumInCrypto = transactionDTO.choosenWallet!.availableAmount
            
            blockchain = BlockchainType.create(wallet: transactionDTO.choosenWallet!).blockchain
            
            if transactionDTO.sendAmountString != nil {
                sumInCrypto = transactionDTO.sendAmountString!.convertCryptoAmountStringToMinimalUnits(in: blockchain)
            }
            transactionObj = transactionDTO.transaction!.transactionRLM
            cryptoName = transactionDTO.blockchainType!.shortName
            exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
            
            if transactionDTO.transaction?.transactionRLM?.sumInCryptoBigInt != nil {
                feeAmount = BigInt("21000") * transactionDTO.transaction!.transactionRLM?.sumInCryptoBigInt
                feeAmountInFiat = feeAmount * exchangeCourse
            }
            
            maxLengthForSum = transactionDTO.choosenWallet!.blockchainType.blockchain.maxLengthForSum
            maxPrecision = transactionDTO.choosenWallet!.blockchainType.blockchain.maxPrecision
        }
    }
    
    var blockchain: Blockchain = BLOCKCHAIN_BITCOIN
    
    var account = DataManager.shared.realmManager.account
    var blockedAmount = BigInt("0")

    var availableSumInCrypto = BigInt("0")
    
    var availableSumInFiat: BigInt { // It is sum in crypto multiplyed by blockchain.multiplyerToMinimalUnits
        return availableSumInCrypto * exchangeCourse
    }
    var transactionObj: TransactionRLM?
    var exchangeCourse = Double(0.0)
    
    // entered sum
    var sumInCrypto = BigInt("0")
    var sumInFiat = BigInt("0")
    
    var fiatName = "USD"
    var cryptoName = "ETH"
    
    var isCrypto = true
    var isMaxEntered = false
    
    var maxLengthForSum = 0
    var maxPrecision = 0
    
    var sumInNextBtn = BigInt("0")
    var maxAllowedToSpend = BigInt("0")
    var cryptoMaxSumWithFeeAndDonate = BigInt("0")
    
    var feeAmount = BigInt("0")
    var feeAmountInFiat = BigInt("0")
    
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
                                         addressID:     wallet.changeAddressIndex,
                                         binaryData:    &binaryData!)
    }
    
    func estimateTransactionAndValidation() -> Bool {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            return estimateBTCTransactionAndValidation()
        case BLOCKCHAIN_ETHEREUM:
            return estimateETHTransactionAndValidation()
        default:
            return false
        }
    }
    
    func setAmountFromQr() {
        if sumInCrypto > Int64(0) {
            sendAmountVC?.amountTF.text = sumInCrypto.cryptoValueString(for: blockchain)
            sendAmountVC?.topSumLbl.text = sumInCrypto.cryptoValueString(for: blockchain)
            sendAmountVC?.btnSumLbl.text = sumInCrypto.cryptoValueString(for: blockchain)
        }
    }
    
    func cryptoToUsd() {
        self.sendAmountVC?.bottomSumLbl.text = sumInFiat.fiatValueString(for: blockchain) + " "
    }
    
    func usdToCrypto() {
        sumInCrypto = sumInFiat / exchangeCourse
        if sumInCrypto > availableSumInCrypto {
            sendAmountVC?.bottomSumLbl.text = availableSumInCrypto.cryptoValueString(for: blockchain) + " "
        } else {
            sendAmountVC?.bottomSumLbl.text = sumInCrypto.cryptoValueString(for: blockchain) + " "
        }
    }
    
    func setSpendableAmountText() {
        if isCrypto {
            sendAmountVC?.spendableSumAndCurrencyLbl.text = availableSumInCrypto.cryptoValueString(for: blockchain) + " " + cryptoName
        } else {
            sendAmountVC?.spendableSumAndCurrencyLbl.text = availableSumInFiat.fiatValueString(for: blockchain) + " " + fiatName
        }
    }
    
    func getNextBtnSum() -> BigInt {
        if sumInCrypto == Int64(0) {
            return sumInCrypto
        }
        
        let estimate = estimateTransactionAndValidation()
        
        if estimate == false {
            var message = rawTransaction
            
            if message.hasPrefix("BigInt value is not representable as") {
                message = sendAmountVC!.localize(string: Constants.youEnteredTooSmallAmountString)
            } else if message.hasPrefix("Transaction is trying to spend more than available in inputs") {
                message = sendAmountVC!.localize(string: Constants.youEnteredTooSmallAmountString)
            }
            
            let alert = UIAlertController(title: sendAmountVC!.localize(string: Constants.errorString), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in }))
            sendAmountVC!.present(alert, animated: true, completion: nil)
            
            sendAmountVC?.amountTF.text = "0"
            sendAmountVC?.topSumLbl.text = "0"
            saveTfValue()
            checkMaxEntered()
            sendAmountVC?.setSumInNextBtn()
            sendAmountVC?.sendAnalyticsEvent(screenName: "\(screenSendAmountWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: transactionErr)
            
            return BigInt("-1") // error
        }

        return finalSum()
    }
    
    func setMaxAllowed() {       
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            setBTCMaxAllowed()
        case BLOCKCHAIN_ETHEREUM:
            setETHMaxAllowed()
        default:
            return
        }
    }
    
    func saveTfValue() {
        if isCrypto {
            sumInCrypto = sendAmountVC!.topSumLbl.text!.convertCryptoAmountStringToMinimalUnits(in: blockchain)
            sumInFiat = sumInCrypto * exchangeCourse
            
            if sumInFiat > availableSumInFiat {
                sendAmountVC?.bottomSumLbl.text = availableSumInFiat.cryptoValueString(for: blockchain) + " "
            } else {
                sendAmountVC?.bottomSumLbl.text = sumInFiat.fiatValueString(for: blockchain) + " "
            }
            
            sendAmountVC?.bottomCurrencyLbl.text = fiatName
        } else {
            sumInFiat = blockchain.multiplyerToMinimalUnits * Double(sendAmountVC!.topSumLbl.text!.stringWithDot) // fiat * 10^18
            sumInCrypto = sumInFiat / exchangeCourse
            
            if sumInCrypto > availableSumInCrypto {
                sendAmountVC?.bottomSumLbl.text = availableSumInCrypto.cryptoValueString(for: blockchain) + " "
            } else {
                sendAmountVC?.bottomSumLbl.text = sumInCrypto.cryptoValueString(for: blockchain) + " "
            }
            
            sendAmountVC?.bottomCurrencyLbl.text = cryptoName
        }
    }
    
    func checkMaxEntered() {
        if self.isCrypto {
            switch self.sendAmountVC?.commissionSwitch.isOn {
            case true?:
                if self.sumInCrypto >= self.cryptoMaxSumWithFeeAndDonate {
                    self.isMaxEntered = true
                } else {
                    self.isMaxEntered = false
                }
            case false?:
                if self.sumInCrypto >= self.availableSumInCrypto  {
                    self.isMaxEntered = true
                } else {
                    self.isMaxEntered = false
                }
            case .none:
                return
            }
        } else {
            switch self.sendAmountVC?.commissionSwitch.isOn {
            case true?:
                if self.sumInFiat >= self.cryptoMaxSumWithFeeAndDonate {
                    self.isMaxEntered = true
                } else {
                    self.isMaxEntered = false
                }
            case false?:
                if self.sumInFiat >= self.availableSumInFiat  {
                    self.isMaxEntered = true
                } else {
                    self.isMaxEntered = false
                }
            case .none:
                return
            }
        }
    }
    
    func makeMaxSumWithFeeAndDonate() {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            makeBTCMaxSumWithFeeAndDonate()
        case BLOCKCHAIN_ETHEREUM:
            makeETHMaxSumWithFeeAndDonate()
        default:
            return
        }
    }
    
    func messageForAlert() -> String {
        var message = ""
        switch isCrypto {
        case true:
            if transactionDTO.transaction!.donationDTO != nil {
                let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeAndDonationString) +
                    "\(currentCryptoFeeAmountString()) \(self.cryptoName)" +
                    sendAmountVC!.localize(string: Constants.andDonationString) +
                    "\(donationCryptoValue.cryptoValueString(for: blockchain)) \(self.cryptoName)"
            } else {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeString) + "\(currentCryptoFeeAmountString()) \(self.cryptoName)"
            }
        case false:
            if transactionDTO.transaction!.donationDTO != nil {
                let donationCryptoValue = Constants.BigIntSwift.oneBTCInSatoshiKey * transactionDTO.transaction!.donationDTO!.sumInCrypto!
                let donationFiatValue = donationCryptoValue * exchangeCourse
                
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeAndDonationString) +
                    "\(currentFiatFeeAmountString()) \(self.fiatName)" +
                    sendAmountVC!.localize(string: Constants.andDonationString) +
                    "\(donationFiatValue.cryptoValueString(for: blockchain)) \(self.fiatName)"
            } else {
                message = sendAmountVC!.localize(string: Constants.youCantSpendMoreThanFeeString) + "   \(currentFiatFeeAmountString()) \(self.fiatName)"
            }
        }
        
        return message
    }
}

extension CreateTransactionDelegate {
    func estimateBTCTransactionAndValidation() -> Bool {
        if transactionDTO.blockchainType!.blockchain != BLOCKCHAIN_BITCOIN {
            print("\n\n\nnot right screen\n\n\n")
        }
        
        let trData = DataManager.shared.coreLibManager.createTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                                                         sendAddress: transactionDTO.sendAddress!,
                                                                         sendAmountString: self.sumInCrypto.cryptoValueString(for: blockchain),
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
    
    func estimateETHTransactionAndValidation() -> Bool {
        var sendAmount = BigInt("0")
        if sendAmountVC!.commissionSwitch.isOn {
            sendAmount = sumInCrypto
        } else {
            sendAmount = sumInCrypto - feeAmount
        }
        
        let trData = DataManager.shared.coreLibManager.createEtherTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                                                              sendAddress: transactionDTO.sendAddress!,
                                                                              sendAmountString: sendAmount.stringValue,
                                                                              nonce: transactionDTO.choosenWallet!.ethWallet!.nonce.intValue,
                                                                              balanceAmount: "\(transactionDTO.choosenWallet!.ethWallet!.balance)",
            ethereumChainID: UInt32(transactionDTO.choosenWallet!.blockchainType.net_type),
            gasPrice: transactionDTO.transaction?.transactionRLM?.sumInCryptoBigInt.stringValue ?? "0",
            gasLimit: "21000")
        
        rawTransaction = trData.message
        
        return trData.isTransactionCorrect
    }
    
    func finalSum() -> BigInt {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            return finalBTCSum()
        case BLOCKCHAIN_ETHEREUM:
            return finalETHSum()
        default:
            return BigInt("0")
        }
    }
    
    func finalBTCSum() -> BigInt {
        transactionObj?.sumInCrypto = rawTransactionEstimation
        transactionObj?.sumInFiat = rawTransactionEstimation * exchangeCourse
        
        let fiatEstimation = rawTransactionBigIntEstimation * exchangeCourse
        
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
            
            return sumInNextBtn
        }
    }
    
    func finalETHSum() -> BigInt {
        let fiatAmount = feeAmount * exchangeCourse
        
        switch isCrypto {
        case true:
            sumInNextBtn = sumInCrypto
            
            if sendAmountVC!.commissionSwitch.isOn {
                sumInNextBtn = sumInNextBtn + feeAmount
            }
            
            if sumInNextBtn > availableSumInCrypto {
                sumInNextBtn = availableSumInCrypto
            }
        case false:
            sumInNextBtn = sumInFiat
            
            if sendAmountVC!.commissionSwitch.isOn {
                sumInNextBtn = sumInNextBtn + fiatAmount
            }
            
            if sumInNextBtn > availableSumInFiat {
                sumInNextBtn = availableSumInFiat
            }
        }
        
        return sumInNextBtn
    }
    
    func setBTCMaxAllowed() {
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
            let fiatEstimation = rawTransactionBigIntEstimation * exchangeCourse
            
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
    
    func setETHMaxAllowed() {
        switch isCrypto {
        case true:
            if sendAmountVC!.commissionSwitch.isOn {
                maxAllowedToSpend = availableSumInCrypto - feeAmount
            } else {
                maxAllowedToSpend = availableSumInCrypto
            }
        case false:
            if sendAmountVC!.commissionSwitch.isOn {
                maxAllowedToSpend = availableSumInFiat - feeAmountInFiat
            } else {
                maxAllowedToSpend = availableSumInFiat
            }
        }
    }
    
    func makeBTCMaxSumWithFeeAndDonate() {
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
    
    func makeETHMaxSumWithFeeAndDonate() {
        if isCrypto {
            cryptoMaxSumWithFeeAndDonate = availableSumInCrypto - feeAmount
        } else {
            cryptoMaxSumWithFeeAndDonate = availableSumInFiat - feeAmountInFiat
        }
    }
    
    func currentCryptoFeeAmountString() -> String {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            return rawTransactionBigIntEstimation.cryptoValueString(for: BLOCKCHAIN_BITCOIN)
        case BLOCKCHAIN_ETHEREUM:
            return feeAmount.cryptoValueString(for: BLOCKCHAIN_ETHEREUM)
        default:
            return ""
        }
    }
    
    func currentFiatFeeAmountString() -> String {
        var fiatEstimation = BigInt("0")
        
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            fiatEstimation = rawTransactionBigIntEstimation
        case BLOCKCHAIN_ETHEREUM:
            fiatEstimation = feeAmount
        default:
            fiatEstimation = BigInt("0")
        }
        
        return (fiatEstimation * exchangeCourse).cryptoValueString(for: blockchain)
    }
    
    func isEnteredDataAcceptable() -> Bool {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            return sumInCrypto != Int64(0) && transactionDTO.transaction!.donationDTO != nil && sendAmountVC!.amountTF.text!.isEmpty == false && convertBTCStringToSatoshi(sum: sendAmountVC!.amountTF.text!) != 0
        case BLOCKCHAIN_ETHEREUM:
            return sumInCrypto != Int64(0) && sendAmountVC!.amountTF.text!.isEmpty == false
        default:
            return false
        }
    }
}
