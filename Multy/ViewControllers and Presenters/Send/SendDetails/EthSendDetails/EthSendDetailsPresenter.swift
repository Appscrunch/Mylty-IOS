//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias LocalizeDelegate = EthSendDetailsPresenter

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
    
    var cusomtGasPrice: UInt64?
    var cusomtGasLimit: UInt64?
    
    var feeRate: NSDictionary? {
        didSet {
            if let verySlowFeeRate = feeRate?["VerySlow"] as? UInt64 {
                if cusomtGasPrice == nil {
                    cusomtGasPrice = UInt64(verySlowFeeRate)
                }
                
                sendDetailsVC?.tableView.reloadData()
                updateCellsVisibility()
            }
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
        }
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
        if feeRate == nil {
            return
        }
        
        let exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
        switch index {
        case 0:
            self.transactionObj.speedName = localize(string: Constants.veryFastString)
            self.transactionObj.speedTimeString = "∙ 10 minutes"
            self.transactionObj.sumInCryptoBigInt = BigInt("\(feeRate?.object(forKey: "VeryFast") as? UInt64 ?? UInt64(5000000000))")
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 6
        case 1:
            self.transactionObj.speedName = localize(string: Constants.fastString)
            self.transactionObj.speedTimeString = "∙ 6 hour"
            self.transactionObj.sumInCryptoBigInt = BigInt("\(feeRate?.object(forKey: "Fast") as? UInt64 ?? UInt64(4000000000))")
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 10
        case 2:
            self.transactionObj.speedName = localize(string: Constants.mediumString)
            self.transactionObj.speedTimeString = "∙ 5 days"
            self.transactionObj.sumInCryptoBigInt = BigInt("\(feeRate?.object(forKey: "Medium") as? UInt64 ?? UInt64(3000000000))")
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 20
        case 3:
            self.transactionObj.speedName = localize(string: Constants.slowString)
            self.transactionObj.speedTimeString = "∙ 1 week"
            self.transactionObj.sumInCryptoBigInt = BigInt("\(feeRate?.object(forKey: "Slow") as? UInt64 ?? UInt64(2000000000))")
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 50
        case 4:
            self.transactionObj.speedName = localize(string: Constants.verySlowString)
            self.transactionObj.speedTimeString = "∙ 2 weeks"
            self.transactionObj.sumInCryptoBigInt = BigInt("\(feeRate?.object(forKey: "VerySlow") as? UInt64 ?? UInt64(1000000000))")
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = "ETH"
            self.transactionObj.fiatName = "USD"
            self.transactionObj.numberOfBlocks = 70
        case 5:
            self.transactionObj.speedName = localize(string: Constants.customString)
            self.transactionObj.speedTimeString = ""
            self.transactionObj.sumInCryptoBigInt = customGas.gasPrice
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
        self.sendDetailsVC?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
        
    }
    
    func customFeeData(firstValue: Int?, secValue: Int?) {
        print(firstValue)
        if selectedIndexOfSpeed != 5 {
            selectedIndexOfSpeed = 5
        }
        let cell = self.sendDetailsVC?.tableView.cellForRow(at: [0, selectedIndexOfSpeed!]) as! CustomTrasanctionFeeTableViewCell
//        cell.value = firstValue
        self.customGas.gasPrice = BigInt("\(firstValue!)") * Int64(1000000000)
        self.customGas.gasLimit = BigInt("\(firstValue ?? 0)")
        cusomtGasPrice = UInt64(firstValue!) * 1000000000
        cell.value = cusomtGasPrice!
        cell.setupUI()
//        cell.setupUIFor(gasPrice: firstValue!, gasLimit: secValue!)
//        self.customFee = UInt64(firstValue)
//        self.sendDetailsVC?.tableView.reloadData()
        updateCellsVisibility()
        sendDetailsVC?.sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: customFeeSetuped)
        
        
        var cells = sendDetailsVC!.tableView.visibleCells
        cells.removeLast()
        let trueCells = cells as! [TransactionFeeTableViewCell]
        for cell in trueCells {
            cell.checkMarkImage.isHidden = true
        }
        if trueCells.count > 5 {
            trueCells[5].checkMarkImage.isHidden = false
            selectedIndexOfSpeed = 5
        }
    }
    
    func updateCellsVisibility () {
        var cells = sendDetailsVC?.tableView.visibleCells
        let selectedCell = selectedIndexOfSpeed == nil ? nil : cells![selectedIndexOfSpeed!]
        
        for cell in cells! {
            cell.alpha = (cell === selectedCell) ? 1.0 : 0.3
            
            if !cell.isKind(of: CustomTrasanctionFeeTableViewCell.self) {
                (cell as! TransactionFeeTableViewCell).checkMarkImage.isHidden = (cell !== selectedCell)
            }
        }
    }
    
    func setPreviousSelected(index: Int?) {      
        self.sendDetailsVC?.tableView.selectRow(at: [0,index!], animated: false, scrollPosition: .none)
        self.sendDetailsVC?.tableView.delegate?.tableView!(self.sendDetailsVC!.tableView, didSelectRowAt: [0,index!])
        self.selectedIndexOfSpeed = index!
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

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
