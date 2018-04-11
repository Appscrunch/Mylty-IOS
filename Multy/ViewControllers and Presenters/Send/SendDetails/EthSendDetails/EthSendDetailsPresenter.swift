//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class EthSendDetailsPresenter: NSObject, CustomFeeRateProtocol {
    
    var sendDetailsVC: EthSendDetailsViewController?
    var transactionDTO = TransactionDTO()
    var historyArray : List<HistoryRLM>? {
        didSet {
            self.blockedAmount = calculateBlockedAmount()
            availableSumInCrypto = self.transactionDTO.choosenWallet!.sumInCrypto - calculateBlockedAmount().btcValue
            availableSumInFiat = availableSumInCrypto! * transactionDTO.choosenWallet!.exchangeCourse
        }
    }
    
    var blockedAmount           : UInt64?
    var availableSumInCrypto    : Double?
    var availableSumInFiat      : Double?
    
    var selectedIndexOfSpeed: Int?
    
    var cryptoName = "ETH"
    var fiatName = "USD"
    
    //    var addressToStr: String?
    //    var amountFromQr: Double?
    
    var maxAllowedToSpend = 0.0
    
    let transactionObj = TransactionRLM()
    
    let customGas = EthereumGasInfo()
    
    var cusomtGasPrice: Int?
    var cusomtGasLimit: Int?
    
    var feeRate: NSDictionary? {
        didSet {
            sendDetailsVC?.tableView.reloadData()
        }
    }
    
    
    //    self.sumInFiat = Double(round(100*self.sumInFiat)/100)
    func makeCryptoName() {
        self.cryptoName = transactionDTO.choosenWallet!.cryptoName
    }
    
    func getData() {
        DataManager.shared.getAccount { (account, error) in
            if error != nil {
                return
            }
            
            DataManager.shared.getTransactionHistory(currencyID: self.transactionDTO.choosenWallet!.chain,
                                                     networkID:self.transactionDTO.choosenWallet!.chainType,
                                                     walletID: self.transactionDTO.choosenWallet!.walletID) { (histList, err) in
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
        //            })
        //        }
    }
    
    func requestFee() {
        DataManager.shared.getFeeRate(currencyID: transactionDTO.choosenWallet!.chain.uint32Value,
                                      networkID: transactionDTO.choosenWallet!.chainType.uint32Value,
                                      completion: { (dict, error) in
            if dict != nil {
                self.feeRate = dict
            } else {
                print("Did failed getting feeRate")
            }
        })
    }
    
    func createTransaction(index: Int) {
        let exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
        switch index {
        case 0:
            self.transactionObj.speedName = "Very Fast"
            self.transactionObj.speedTimeString = "∙ 10 minutes"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 6
        case 1:
            self.transactionObj.speedName = "Fast"
            self.transactionObj.speedTimeString = "∙ 6 hour"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 10
        case 2:
            self.transactionObj.speedName = "Normal"
            self.transactionObj.speedTimeString = "∙ 5 days"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 20
        case 3:
            self.transactionObj.speedName = "Slow"
            self.transactionObj.speedTimeString = "∙ 1 week"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 50
        case 4:
            self.transactionObj.speedName = "Very Slow"
            self.transactionObj.speedTimeString = "∙ 2 weeks"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 70
        case 5:
            self.transactionObj.speedName = "Custom"
            self.transactionObj.speedTimeString = ""
//            self.transactionObj.sumInCrypto = convertSatoshiToBTC(sum: self.customFee)
            self.transactionObj.sumInFiat = 0.0
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 0
        default:
            return
        }
    }
    
    
    func setMaxAllowed() {
        //        self.maxAllowedToSpend = (self.choosenWallet?.availableSumInCrypto)! - self.trasactionObj.sumInCrypto
    }
    
    func checkMaxAvailable() {
//        if self.availableSumInCrypto == nil || availableSumInCrypto! < 0.0 {
//            self.sendDetailsVC?.presentWarning(message: "Wrong wallet data. Please download wallet data again.")
//            
//            return
//        }
        
//        self.maxAllowedToSpend = self.availableSumInCrypto!
        
        self.sendDetailsVC?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
        
    }
    
    func customFeeData(firstValue: Int?, secValue: Int?) {
        print(firstValue)
        if selectedIndexOfSpeed != 5 {
            selectedIndexOfSpeed = 5
        }
        let cell = self.sendDetailsVC?.tableView.cellForRow(at: [0, selectedIndexOfSpeed!]) as! CustomTrasanctionFeeTableViewCell
//        cell.value = firstValue
        self.customGas.gasPrice = firstValue!
        self.customGas.gasLimit = secValue!
        cell.setupUIFor(gasPrice: firstValue!, gasLimit: secValue!)
//        self.customFee = UInt64(firstValue)
        self.sendDetailsVC?.tableView.reloadData()
        sendDetailsVC?.sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: customFeeSetuped)
    }
    
    func setPreviousSelected(index: Int?) {
        
    }
    
    //==============================
    
    func calculateBlockedAmount() -> UInt64 {
        var sum = UInt64(0)
        
        if transactionDTO.choosenWallet == nil {
            return sum
        }
        
        if historyArray?.count == 0 {
            return sum
        }
        
        //        for address in wallet!.addresses {
        //            for out in address.spendableOutput {
        //                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue {
        //                    sum += out.transactionOutAmount.uint64Value
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
    
    func blockedAmount(for transaction: HistoryRLM) -> UInt64 {
        var sum = UInt64(0)
        
        if transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            sum += transaction.txOutAmount.uint64Value
        } else if transaction.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            let addresses = transactionDTO.choosenWallet!.fetchAddresses()
            
            for tx in transaction.txOutputs {
                if addresses.contains(tx.address) {
                    sum += tx.amount.uint64Value
                }
            }
        }
        
        return sum
    } 
}
