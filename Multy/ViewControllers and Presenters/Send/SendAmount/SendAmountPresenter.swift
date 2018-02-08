//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class SendAmountPresenter: NSObject {
    
    var sendAmountVC: SendAmountViewController?
    var account: AccountRLM?
    
    //MARK: fix addresses in wallet and delete second ivar
    var wallet: UserWalletRLM?
    var historyArray : List<HistoryRLM>? {
        didSet {
            self.blockedAmount = calculateBlockedAmount()
        }
    }
    
    var blockedAmount           : UInt32? {
        didSet {
            availableSumInCrypto = self.wallet!.sumInCrypto - convertSatoshiToBTC(sum: calculateBlockedAmount())
            availableSumInFiat = availableSumInCrypto! * exchangeCourse
        }
    }
    var availableSumInCrypto    : Double?
    var availableSumInFiat      : Double?
    
    var walletAddresses: List<AddressRLM>?
    
    var transactionObj: TransactionRLM?
    var donationObj: DonationObj?
    
    var addressToStr: String?
    
    var sumInCrypto = Double(round(100000000*0.0)/100000000)
    var sumInFiat = Double(round(100*0.0)/100)
    
    var fiatName = "USD"
    var cryptoName = "BTC"
    
    var isCrypto = true
    var isMaxEntered = false
    
    var maxLengthForSum = 12
    
    var sumInNextBtn = 0.0
    var maxAllowedToSpend = 0.0
    var cryptoMaxSumWithFeeAndDonate = 0.0
    
    var rawTransaction: String?
    
    var customFee : UInt32?
    
    //for creating transaction
    var binaryData : BinaryData?
    var addressData : Dictionary<String, Any>?
    
    func getData() {
        DataManager.shared.getAccount { (account, error) in
            self.account = account
            
            self.createPreliminaryData()
            
            DataManager.shared.getTransactionHistory(currencyID: self.wallet!.chain, walletID: self.wallet!.walletID) { (histList, err) in
                if err == nil && histList != nil {
                    self.historyArray = histList!
                }
            }
        }
    }
    
    func createPreliminaryData() {
        let core = DataManager.shared.coreLibManager
        let wallet = self.wallet!
        binaryData = account!.binaryDataString.createBinaryData()!
        
        
        //Example for addressData
        //        ["privateKey": "2bdeccJBhnRiDz5cSaHhxfiAoACGaQzfbZizmK7KNqbvtP4Bmc",
        //         "addressIndex": 0,
        //         "addressPrivateKeyPointer": 0x0000000174456560,
        //         "addressPointer": 0x0000000174289ce0,
        //         "address": "mzNZBhim9XGy66FkdzrehHwdWNgbiTYXCQ",
        //         "walletIndex": 0,
        //         "currencyID": 0,
        //         "publicKey": "NkWaWtGAq2MA2wkQaZ4s66HttE598b3Bqc7CueS9J3ry7zvBLG76us11eTxkpVYH7th1z5SKDP3oNMJxGyZe8zRv"]
        addressData = core.createAddress(currencyID:    wallet.chain.uint32Value,
                                         walletID:      wallet.walletID.uint32Value,
                                         addressID:     UInt32(wallet.addresses.count),
                                         binaryData:    &binaryData!)
    }
    
    func estimateTransaction() -> Double {

        
        let feeAmount = DataManager.shared.coreLibManager.getTotalFee(addressPointer: addressData!["addressPointer"] as! OpaquePointer,
                                                                      feeAmountString: "\(customFee!)",
                                                                      isDonationExists: donationObj?.sumInCrypto != Double(0.0),
                                                                      isPayCommission: self.sendAmountVC!.commissionSwitch.isOn,
                                                                      inputsCount: DataManager.shared.realmManager.spendableOutput(addresses: wallet!.addresses).count)
        
//        let feeRateOld = core.getTotalFeeAndInputs(addressPointer: addressData!["addressPointer"] as! OpaquePointer,
//                                                sendAmountString: String(self.sumInCrypto),
//                                                feeAmountString: "50",
//                                                isDonationExists: true,
//                                                donationAmount: String(describing: self.donationObj!.sumInCrypto!),
//                                                isPayCommission: self.sendAmountVC!.commissionSwitch.isOn,
//                                                wallet: wallet)
        
        let trData = DataManager.shared.coreLibManager.createTransaction(addressPointer: addressData!["addressPointer"] as! OpaquePointer,
                                                                         sendAddress: self.addressToStr!,
                                                                         sendAmountString: self.sumInCrypto.fixedFraction(digits: 8),
                                                                         feePerByteAmount: "\(customFee!)",
                                                                         isDonationExists: true,
                                                                         donationAmount: self.donationObj!.sumInCrypto!.fixedFraction(digits: 8),
                                                                         isPayCommission: self.sendAmountVC!.commissionSwitch.isOn,
                                                                         wallet: wallet!,
                                                                         binaryData: &binaryData!,
                                                                         feeAmount: feeAmount,
                                                                         inputs: wallet!.addresses)
        
        self.rawTransaction = trData.0
        
        return trData.1
        
        //        let params = [
        //            "transaction" : trData.0
        //            ] as [String : Any]
        
//        DataManager.shared.apiManager.sendRawTransaction(account!.token, walletID: wallet.walletID, params, completion: { (dict, error) in
//            print("---------\(dict)")
//        })
        
//        print("feeRate: \(feeRate)")
        //            let outputs = DataManager.shared.fetchSpendableOutput(wallet: presenter.wallet!)
        //            let subset = DataManager.shared.greedySubSet(outputs: outputs, threshold: 130000)
    }
    
    func setAmountFromQr() {
        if self.sumInCrypto != 0.0 {
            self.sendAmountVC?.amountTF.text = self.sumInCrypto.fixedFraction(digits: 8)
            self.sendAmountVC?.topSumLbl.text = self.sumInCrypto.fixedFraction(digits: 8)
            self.sendAmountVC?.btnSumLbl.text = self.sumInCrypto.fixedFraction(digits: 8)
        }
    }
    
    func cryptoToUsd() {
        self.sumInFiat = self.sumInCrypto * exchangeCourse
        self.sumInFiat = Double(round(100 * self.sumInFiat)/100)
        self.sendAmountVC?.bottomSumLbl.text = "\(self.sumInFiat.fixedFraction(digits: 2)) "
    }
    
    func usdToCrypto() {
        self.sumInCrypto = self.sumInFiat/exchangeCourse
        self.sumInCrypto = Double(round(100000000 * self.sumInCrypto)/100000000)
        if self.sumInCrypto > self.availableSumInCrypto! {
            self.sendAmountVC?.bottomSumLbl.text = "\((self.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8))"
        } else {
            self.sendAmountVC?.bottomSumLbl.text = "\((self.sumInCrypto).fixedFraction(digits: 8))"
        }
    }
    
    func setSpendableAmountText() {
        if self.isCrypto {
            self.sendAmountVC?.spendableSumAndCurrencyLbl.text = "\((self.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)"
        } else {
            self.sendAmountVC?.spendableSumAndCurrencyLbl.text = "\((self.availableSumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)"
        }
    }
    
    func getNextBtnSum() -> Double {
        let satoshiAmount = UInt32(sumInCrypto * pow(10, 8))
        let estimate = satoshiAmount == 0 ? 0.0 : estimateTransaction()
        
        if estimate < 0 {
            
            let message = "Please, check destination bitcoin address and enter correct one"
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in }))
            sendAmountVC!.present(alert, animated: true, completion: nil)
            
            sendAmountVC?.amountTF.text = "0.0"
            
            return 0.0
        }
        
        self.transactionObj?.sumInCrypto = estimate
        self.transactionObj?.sumInFiat = estimate * exchangeCourse
        
        switch self.isCrypto {
        case true:
            if (self.sendAmountVC?.commissionSwitch.isOn)! {
                if self.donationObj != nil {
                    self.sumInNextBtn = self.sumInCrypto + (self.transactionObj?.sumInCrypto)! + (self.donationObj?.sumInCrypto)!
                } else {
                    self.sumInNextBtn = self.sumInCrypto + (self.transactionObj?.sumInCrypto)!
                }
            } else {  //pay for commision off
                self.sumInNextBtn = self.sumInCrypto
            }
            if self.sumInNextBtn > self.availableSumInCrypto! {
                self.sumInNextBtn = self.availableSumInCrypto ?? 0.0
            }
            return Double(round(100000000 * self.sumInNextBtn)/100000000)
        case false:
            if (self.sendAmountVC?.commissionSwitch.isOn)! {
                if self.donationObj != nil {
                    self.sumInNextBtn = self.sumInFiat + (self.transactionObj?.sumInFiat)! + (self.donationObj?.sumInFiat)!
                } else {
                    self.sumInNextBtn = self.sumInFiat + (self.transactionObj?.sumInFiat)!
                }
            } else {  //pay for commision off
                self.sumInNextBtn = self.sumInFiat
            }
            if self.sumInNextBtn > self.availableSumInFiat! {
                self.sumInNextBtn = self.availableSumInFiat ?? 0.0
            }
            
            return self.sumInNextBtn
        }
    }
    
    func setMaxAllowed() {
        switch self.isCrypto {
        case true:
            if (self.sendAmountVC?.commissionSwitch.isOn)! {
                if self.donationObj != nil {
                    self.maxAllowedToSpend = self.availableSumInCrypto! - (self.transactionObj?.sumInCrypto)! - (self.donationObj?.sumInCrypto)!
                } else {
                    self.maxAllowedToSpend = self.availableSumInCrypto! - (self.transactionObj?.sumInCrypto)!
                }
            } else {
                self.maxAllowedToSpend = self.availableSumInCrypto!
            }
        case false:
            if (self.sendAmountVC?.commissionSwitch.isOn)! {
                if self.donationObj != nil {
                    self.maxAllowedToSpend = self.availableSumInFiat! - self.transactionObj!.sumInFiat - self.donationObj!.sumInFiat!
                } else {
                    self.maxAllowedToSpend = self.availableSumInFiat! - self.transactionObj!.sumInFiat
                }
            } else {
                self.maxAllowedToSpend = (self.availableSumInFiat)!
            }
        }
    }
    
    func saveTfValue() {
        if self.isCrypto {
            self.sumInCrypto = self.sendAmountVC!.topSumLbl.text!.toStringWithComma()
            self.sumInFiat = self.sumInCrypto * exchangeCourse
            self.sumInFiat = Double(round(100 * self.sumInFiat)/100)
            if self.sumInFiat > self.wallet!.sumInFiat {
                self.sendAmountVC?.bottomSumLbl.text = "\((self.wallet?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) "
            } else {
                self.sendAmountVC?.bottomSumLbl.text = "\(self.sumInFiat.fixedFraction(digits: 2)) "
            }
            self.sendAmountVC?.bottomCurrencyLbl.text = self.fiatName
        } else {
            self.sumInFiat = self.sendAmountVC!.topSumLbl.text!.toStringWithComma()
            self.sumInCrypto = self.sumInFiat / exchangeCourse
            self.sumInCrypto = Double(round(100000000 * self.sumInCrypto)/100000000)
            if self.sumInCrypto > self.availableSumInCrypto! {
                self.sendAmountVC?.bottomSumLbl.text = "\((self.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8)) "
            } else {
                self.sendAmountVC?.bottomSumLbl.text = "\(self.sumInCrypto.fixedFraction(digits: 8)) "
            }
            
            self.sendAmountVC?.bottomCurrencyLbl.text = self.cryptoName
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
                if self.sumInCrypto >= self.availableSumInCrypto!  {
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
                if self.sumInFiat >= self.availableSumInFiat!  {
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
        if self.isCrypto {
            if self.donationObj != nil {
                self.cryptoMaxSumWithFeeAndDonate = self.availableSumInCrypto! - (self.transactionObj?.sumInCrypto)! - (self.donationObj?.sumInCrypto)!
            } else {
                self.cryptoMaxSumWithFeeAndDonate = self.availableSumInCrypto! - (self.transactionObj?.sumInCrypto)!
            }
        } else {
            if self.donationObj != nil {
                self.cryptoMaxSumWithFeeAndDonate = self.availableSumInFiat! - (self.transactionObj?.sumInFiat)! - (self.donationObj?.sumInFiat)!
            } else {
                self.cryptoMaxSumWithFeeAndDonate = self.availableSumInFiat! - self.transactionObj!.sumInFiat
            }
        }
    }
    
    func messageForAlert() -> String {
        var message = ""
        switch isCrypto {
        case true:
            if self.donationObj != nil {
                message = "You can`t spend sum more than you have!\nDon`t forget about Fee and donation.\n\nYour fee is \((self.transactionObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName) \nand donation is \((self.donationObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)"
            } else {
                message = "You can`t spend sum more than you have!\nDon`t forget about Fee.\nYour is fee \((self.transactionObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)"
            }
        case false:
            if self.donationObj != nil {
                message = "You can`t spend sum more than you have!\nDon`t forget about Fee and donation.\n\nYour fee is \((self.transactionObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName) \nand donation is \((self.donationObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)"
            } else {
                message = "You can`t spend sum more than you have!\nDon`t forget about Fee.\nYour is fee \((self.transactionObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(self.fiatName)"
            }
        }
        return message
    }
    
    func calculateBlockedAmount() -> UInt32 {
        var sum = UInt32(0)
        
        if wallet == nil {
            return sum
        }
        
        if historyArray?.count == 0 {
            return sum
        }
        
        //        for address in wallet!.addresses {
        //            for out in address.spendableOutput {
        //                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue {
        //                    sum += out.transactionOutAmount.uint32Value
        //                } else if out.transactionStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
        //                    out.
        //                }
        //            }
        //        }
        
        for history in historyArray! {
            sum += blockedAmount(for: history)
        }
        
        return sum
    }
    
    func blockedAmount(for transaction: HistoryRLM) -> UInt32 {
        var sum = UInt32(0)
        
        if transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            sum += transaction.txOutAmount.uint32Value
        } else if transaction.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            let addresses = wallet!.fetchAddresses()
            
            for tx in transaction.txOutputs {
                if addresses.contains(tx.address) {
                    sum += tx.amount.uint32Value
                }
            }
        }
        
        return sum
    }
}
