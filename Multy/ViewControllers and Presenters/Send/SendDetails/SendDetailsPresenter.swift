//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class SendDetailsPresenter: NSObject, CustomFeeRateProtocol {
    
    var sendDetailsVC: SendDetailsViewController?
    
    var choosenWallet: UserWalletRLM?
    var walletAddresses: List<AddressRLM>?
    var historyArray : List<HistoryRLM>? {
        didSet {
            self.blockedAmount = calculateBlockedAmount()
            availableSumInCrypto = self.choosenWallet!.sumInCrypto - convertSatoshiToBTC(sum: calculateBlockedAmount())
            availableSumInFiat = availableSumInCrypto! * exchangeCourse
        }
    }
    
    var blockedAmount           : UInt32?
    var availableSumInCrypto    : Double?
    var availableSumInFiat      : Double?
    
    var selectedIndexOfSpeed: Int?
    
    var donationInCrypto: Double? = 0.0001
    var donationInFiat: Double?
    var cryptoName = "BTC"
    var fiatName = "USD"
    
    var addressToStr: String?
    var amountFromQr: Double?
    
    var maxAllowedToSpend = 0.0
    
    let trasactionObj = TransactionRLM()
    
    let donationObj = DonationObj()
    

    var customFee = UInt32(20)
    
    var feeRate: NSDictionary?{
        didSet {
            sendDetailsVC?.tableView.reloadData()
        }
    }

    
//    self.sumInFiat = Double(round(100*self.sumInFiat)/100)
    
    func getData() {
        DataManager.shared.getAccount { (account, error) in
            if error != nil {
                return
            }
            
            DataManager.shared.getTransactionHistory(currencyID: self.choosenWallet!.chain, walletID: self.choosenWallet!.walletID) { (histList, err) in
                if err == nil && histList != nil {
                    self.historyArray = histList!
                }
            }
        }
    }
    
    func getWalletVerbose() {
        //MARK: implement changes
        
//        DataManager.shared.getAccount { (account, err) in
//            DataManager.shared.getOneWalletVerbose(account!.token,
//                                                   walletID: self.choosenWallet!.walletID,
//                                                   completion: { (addresses, error) in
//                self.walletAddresses = addresses
//            })
//        }
    }
    
    func requestFee() {
        DataManager.shared.getFeeRate(currencyID: 0, completion: { (dict, error) in
            if dict != nil {
                self.feeRate = dict
            } else {
                print("Did failed getting feeRate")
            }
        })
    }
    
    func createTransaction(index: Int) {
        switch index {
        case 0:
            self.trasactionObj.speedName = "Very Fast"
            self.trasactionObj.speedTimeString = "∙ 10 minutes"
            self.trasactionObj.sumInCrypto = 0.0001
            self.trasactionObj.sumInFiat = Double(round(100*self.trasactionObj.sumInCrypto * exchangeCourse)/100)
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 6
        case 1:
            self.trasactionObj.speedName = "Fast"
            self.trasactionObj.speedTimeString = "∙ 6 hour"
            self.trasactionObj.sumInCrypto = 0.0001
            self.trasactionObj.sumInFiat = Double(round(100*self.trasactionObj.sumInCrypto * exchangeCourse)/100)
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 10
        case 2:
            self.trasactionObj.speedName = "Medium"
            self.trasactionObj.speedTimeString = "∙ 5 days"
            self.trasactionObj.sumInCrypto = 0.0001
            self.trasactionObj.sumInFiat = Double(round(100*self.trasactionObj.sumInCrypto * exchangeCourse)/100)
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 20
        case 3:
            self.trasactionObj.speedName = "Slow"
            self.trasactionObj.speedTimeString = "∙ 1 week"
            self.trasactionObj.sumInCrypto = 0.0001
            self.trasactionObj.sumInFiat = Double(round(100*self.trasactionObj.sumInCrypto * exchangeCourse)/100)
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 50
        case 4:
            self.trasactionObj.speedName = "Very Slow"
            self.trasactionObj.speedTimeString = "∙ 2 weeks"
            self.trasactionObj.sumInCrypto = 0.0001
            self.trasactionObj.sumInFiat = Double(round(100*self.trasactionObj.sumInCrypto * exchangeCourse)/100)
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 70
        case 5:
            self.trasactionObj.speedName = "Custom"
            self.trasactionObj.speedTimeString = ""
            self.trasactionObj.sumInCrypto = convertSatoshiToBTC(sum: self.customFee)
            self.trasactionObj.sumInFiat = 0.0
            self.trasactionObj.cryptoName = "BTC"
            self.trasactionObj.fiatName = "USD"
            self.trasactionObj.numberOfBlocks = 0
        default:
            return
        }
    }
    
    func createDonation() {
        self.donationObj.sumInCrypto = self.donationInCrypto
        self.donationObj.cryptoName = self.cryptoName
        self.donationObj.sumInFiat = Double(round(100*self.donationInCrypto!*exchangeCourse/100))
        self.donationObj.fiatName = self.fiatName
    }
    
    func nullifyDonation() {
        self.donationObj.sumInCrypto = 0.0
        self.donationObj.cryptoName = ""
        self.donationObj.sumInFiat = 0.0
        self.donationObj.fiatName = ""
    }
    
    func setMaxAllowed() {
//        self.maxAllowedToSpend = (self.choosenWallet?.availableSumInCrypto)! - self.trasactionObj.sumInCrypto
    }
    
    func checkMaxAvailable() {
        if self.availableSumInCrypto == nil || availableSumInCrypto! < 0.0 {
            self.sendDetailsVC?.presentWarning(message: "Wrong wallet data. Please download wallet data again.")
            
            return
        }
        
        if !sendDetailsVC!.isDonateAvailableSW.isOn {
            self.sendDetailsVC?.performSegue(withIdentifier: "sendAmountVC", sender: Any.self)
            
            return
        }
        
        self.maxAllowedToSpend = self.availableSumInCrypto!

//        self.maxAllowedToSpend = (self.choosenWallet?.sumInCrypto)! - self.trasactionObj.sumInCrypto
        if self.donationObj.sumInCrypto! > self.maxAllowedToSpend  {
//            self.sendDetailsVC?.presentWarning(message: "Your donation sum and fee cost more than you have in wallet.\n\n Fee cost: \(self.trasactionObj.sumInCrypto) \(self.trasactionObj.cryptoName)\n Donation sum: \(self.donationObj.sumInCrypto ?? 0.0) \(self.cryptoName)\n Sum in Wallet: \(self.choosenWallet?.sumInCrypto ?? 0.0) \(self.cryptoName)")
            self.sendDetailsVC?.presentWarning(message: "Your donation more than you have in wallet.\n\nDonation sum: \((self.donationObj.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)\n Sum in Wallet: \((self.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)")
        } else if self.donationObj.sumInCrypto! == self.maxAllowedToSpend {
            self.sendDetailsVC?.presentWarning(message: "Your donation is equal your wallet sum.\n\nDonation sum: \((self.donationObj.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(self.cryptoName)\n Sum in Wallet: \((self.availableSumInCrypto ?? 0.0).fixedFraction(digits: 2)) \(self.cryptoName)")
        } else {
            self.sendDetailsVC?.performSegue(withIdentifier: "sendAmountVC", sender: Any.self)
        }
    }
    
    func customFeeData(firstValue: Double, secValue: Double) {
        print(firstValue)
        if selectedIndexOfSpeed != 5 {
           selectedIndexOfSpeed = 5
        }
        let cell = self.sendDetailsVC?.tableView.cellForRow(at: [0, selectedIndexOfSpeed!]) as! CustomTrasanctionFeeTableViewCell
        cell.value = firstValue
        cell.setupUIForBtc()
        self.customFee = UInt32(firstValue)
        self.sendDetailsVC?.tableView.reloadData()
    }
    
    //==============================
    
    func calculateBlockedAmount() -> UInt32 {
        var sum = UInt32(0)
        
        if choosenWallet == nil {
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
            let addresses = choosenWallet!.fetchAddresses()
            
            for tx in transaction.txOutputs {
                if addresses.contains(tx.address) {
                    sum += tx.amount.uint32Value
                }
            }
        }
        
        return sum
    }
}
