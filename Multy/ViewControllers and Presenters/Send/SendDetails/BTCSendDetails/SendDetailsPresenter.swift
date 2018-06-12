//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias LocalizeDelegate = SendDetailsPresenter

class SendDetailsPresenter: NSObject, CustomFeeRateProtocol {
    
    var sendDetailsVC: SendDetailsViewController?
    var transactionDTO = TransactionDTO() {
        didSet {
            self.blockedAmount = transactionDTO.choosenWallet?.calculateBlockedAmount()
            availableSumInCrypto = self.transactionDTO.choosenWallet!.sumInCrypto - self.blockedAmount!.btcValue
            availableSumInFiat = availableSumInCrypto! * transactionDTO.choosenWallet!.exchangeCourse
            cryptoName = transactionDTO.blockchain!.shortName
            customFee = transactionDTO.transaction?.customFee ?? UInt64(0)
        }
    }
    
    var blockedAmount           : UInt64?
    var availableSumInCrypto    : Double?
    var availableSumInFiat      : Double?
    
    var selectedIndexOfSpeed: Int?
    
    var donationInCrypto: Double? = 0.0001
    var donationInFiat: Double?
    var cryptoName = "BTC"
    var fiatName = "USD"
    
//    var addressToStr: String?
//    var amountFromQr: Double?
    
    var maxAllowedToSpend = 0.0
    
    let transactionObj = TransactionRLM()
    let donationObj = DonationDTO()
    var customFee = UInt64(0)
    
    var feeRate: NSDictionary? {
        didSet {
            if let verySlowFeeRate = feeRate?["VerySlow"] as? UInt64 {
                if customFee == 0 {
                    customFee = verySlowFeeRate
                }
                
                sendDetailsVC?.tableView.reloadData()
                updateCellsVisibility()
            }
        }
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
                                      completion: { [unowned self] (dict, error) in
                                        self.sendDetailsVC?.loader.hide()
                                        
                                        if dict != nil {
                                            self.feeRate = dict
                                        } else {
                                            //Default values
                                            self.feeRate = ["VeryFast" : 32,
                                                            "Fast" : 16,
                                                            "Medium" : 8,
                                                            "Slow" : 4,
                                                            "VerySlow" : 2,
                                            ]
                                            print("Did failed getting feeRate")
                                        }
        })
    }
    
    func createTransaction(index: Int) {
        let exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
        switch index {
        case 0:
            self.transactionObj.speedName = localize(string: Constants.veryFastString)
            self.transactionObj.speedTimeString = "∙ 10 minutes"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 6
        case 1:
            self.transactionObj.speedName = localize(string: Constants.fastString)
            self.transactionObj.speedTimeString = "∙ 6 hour"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 10
        case 2:
            self.transactionObj.speedName = localize(string: Constants.mediumString)
            self.transactionObj.speedTimeString = "∙ 5 days"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 20
        case 3:
            self.transactionObj.speedName = localize(string: Constants.slowString)
            self.transactionObj.speedTimeString = "∙ 1 week"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 50
        case 4:
            self.transactionObj.speedName = localize(string: Constants.verySlowString)
            self.transactionObj.speedTimeString = "∙ 2 weeks"
            self.transactionObj.sumInCrypto = 0.00000005
            self.transactionObj.sumInFiat = Double(round(100*self.transactionObj.sumInCrypto * exchangeCourse)/100)
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 70
        case 5:
            self.transactionObj.speedName = localize(string: Constants.customString)
            self.transactionObj.speedTimeString = ""
            self.transactionObj.sumInCrypto = self.customFee.btcValue
            self.transactionObj.sumInFiat = 0.0
            self.transactionObj.cryptoName = cryptoName
            self.transactionObj.fiatName = fiatName
            self.transactionObj.numberOfBlocks = 0
        default:
            return
        }
    }
    
    func createDonation() {
        let exchangeCourse = transactionDTO.choosenWallet!.exchangeCourse
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
            self.sendDetailsVC?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
            
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
            self.sendDetailsVC?.performSegue(withIdentifier: "sendEthVC", sender: Any.self)
        }
    }
    
    func customFeeData(firstValue: Int?, secValue: Int?) {
        print(firstValue)
        if selectedIndexOfSpeed != 5 {
           selectedIndexOfSpeed = 5
        }
        let cell = self.sendDetailsVC?.tableView.cellForRow(at: [0, selectedIndexOfSpeed!]) as! CustomTrasanctionFeeTableViewCell
        cell.value = UInt64(firstValue!)
        cell.setupUI()
        customFee = UInt64(firstValue!)
//        self.sendDetailsVC?.tableView.reloadData()
        updateCellsVisibility()
        sendDetailsVC?.sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(transactionDTO.choosenWallet!.chain)", eventName: customFeeSetuped)
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
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
