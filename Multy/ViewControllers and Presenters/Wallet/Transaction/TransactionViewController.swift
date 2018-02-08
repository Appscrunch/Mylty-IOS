//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class TransactionViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var transactionImg: UIImageView!
    @IBOutlet weak var transctionSumLbl: UILabel! // +0.0152 receive | -0.0123 send
    @IBOutlet weak var transactionCurencyLbl: UILabel! // BTC | ETH
    @IBOutlet weak var sumInFiatLbl: UILabel! //+1 174 USD receive | -1 123 EUR send
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var walletFromAddressLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!  // downArrow receive | upArrow send
    @IBOutlet weak var blockchainImg: UIImageView!
    @IBOutlet weak var personNameLbl: UILabel!   // To Vadim
    @IBOutlet weak var walletToAddressLbl: UILabel!
    @IBOutlet weak var numberOfConfirmationLbl: UILabel! // 6 Confirmations
    @IBOutlet weak var viewInBlockchainBtn: UIButton!
    @IBOutlet weak var constraintNoteFiatSum: NSLayoutConstraint! // set 20 if note == ""
    
    @IBOutlet weak var donationView: UIView!
    @IBOutlet weak var donationCryptoSum: UILabel!
    @IBOutlet weak var donationCryptoName: UILabel!
    @IBOutlet weak var donationFiatSumAndName: UILabel!
    @IBOutlet weak var constraintDonationHeight: NSLayoutConstraint!
    
    let presenter = TransactionPresenter()
    
    var isForReceive = true
    var cryptoName = "BTC"
    
    var sumInCripto = 1.125
    var fiatSum = 1255.23
    var fiatName = "USD"
    
    var isIncoming = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.transctionVC = self
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.isIncoming = presenter.histObj.isIncoming()
        self.checkHeightForSrollAvailability()
        self.checkForSendOrReceive()
        self.constraintDonationHeight.constant = 0
        self.donationView.isHidden = true
        self.updateUI()
    }

    func checkHeightForSrollAvailability() {
//        if screenHeight >= 667 {
//            self.scrollView.isScrollEnabled = false
//        }
    }
    
    func checkForSendOrReceive() {
        if isIncoming {  // RECEIVE
            self.makeBackColor(color: self.presenter.receiveBackColor)
            self.titleLbl.text = "Received BTC"
        } else {                        // SEND
            self.makeBackColor(color: self.presenter.sendBackColor)
            self.titleLbl.text = "Sended \(self.cryptoName)"
            self.transactionImg.image = #imageLiteral(resourceName: "sendBigIcon")
//            self.transctionSumLbl.text = "-\(self.sumInCripto)"
//            self.transactionCurencyLbl.text = self.cryptoName.uppercased()
//            self.sumInFiatLbl.text = "-\(self.fiatSum) \(self.fiatName)"
//            self.constraintNoteFiatSum.constant = 15 // make check of note

//            self.walletFromAddressLbl.text = "" //Set address from here
//            self.blockchainImg.image // Set blockchain image here
//            self.personNameLbl.text = ""  // Set name from address book
//            self.walletToAddressLbl.text = "" // Set address to here
//            self.numberOfConfirmationLbl.text = "" // Set information from sockets here
            
        }
    }
    
    func updateUI() {
        //Receive
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, d MMMM yyyy"
        
        let cryptoSumInBTC = convertSatoshiToBTC(sum: UInt32(truncating: presenter.histObj.txOutAmount))
        
        if presenter.histObj.txStatus.intValue == TxStatus.MempoolIncoming.rawValue ||
            presenter.histObj.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            self.dateLbl.text = dateFormatter.string(from: presenter.histObj.mempoolTime)
        } else {
            self.dateLbl.text = dateFormatter.string(from: presenter.histObj.blockTime)
        }
        
        self.noteLbl.text = "" // NOTE FROM HIST OBJ
        self.constraintNoteFiatSum.constant = 10
        
        let arrOfInputsAddresses = presenter.histObj.txInputs.map{ $0.address }.joined(separator: "\n")   // top address lbl
        
//        self.transactionCurencyLbl.text = presenter.histObj.     // check currencyID
        self.walletFromAddressLbl.text = arrOfInputsAddresses
        self.personNameLbl.text = ""   // before we don`t have address book    OR    Wallet Name
        
        let arrOfOutputsAddresses = presenter.histObj.txOutputs.map{ $0.address }.joined(separator: "\n")
        
        self.walletToAddressLbl.text = arrOfOutputsAddresses
        
        self.numberOfConfirmationLbl.text = makeConfirmationText()
        
        if isIncoming {
            self.transctionSumLbl.text = "+\(cryptoSumInBTC.fixedFraction(digits: 8))"
            self.sumInFiatLbl.text = "+\((cryptoSumInBTC * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
        } else {
            self.transctionSumLbl.text = "-\(cryptoSumInBTC.fixedFraction(digits: 8))"
            self.sumInFiatLbl.text = "-\((cryptoSumInBTC * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
            if let donatAddress = UserDefaults.standard.string(forKey: "BTCDonationAddress") {
                if arrOfOutputsAddresses.contains(donatAddress) {
                    let donatOutPutObj = getDonationTxOutput(address: donatAddress)
                    if donatOutPutObj == nil {
                        return
                    }
                    let btcDonation = convertSatoshiToBTC(sum: donatOutPutObj?.amount as! UInt32)
                    self.donationView.isHidden = false
                    self.constraintDonationHeight.constant = 283
                    self.donationCryptoSum.text = btcDonation.fixedFraction(digits: 8)
                    self.donationCryptoName.text = " BTC"
                    self.donationFiatSumAndName.text = "\((btcDonation * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
                }
            }
        }
    }
    
    func getDonationTxOutput(address: String) -> TxHistoryRLM? {
        for output in presenter.histObj.txOutputs {
            if output.address == address {
                return output
            }
        }

        return nil
    }
    
    func makeBackColor(color: UIColor) {
        self.backView.backgroundColor = color
        self.scrollView.backgroundColor = color
    }
    
    @IBAction func closeAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewInBlockchainAction(_ sender: Any) {
        self.performSegue(withIdentifier: "viewInBlockchain", sender: nil)
    }
    
    
    func makeConfirmationText() -> String {
        var textForConfirmations = ""
        switch presenter.histObj.confirmations {
        case 0:
            textForConfirmations = "Transaction In Mempool"
        case 1-6:
            textForConfirmations = "1-6 Confirmations"
        case nil:
            textForConfirmations = "Information not found"
        default: // more than 6
            textForConfirmations = "6+ Confirmations"
        }
        return textForConfirmations
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewInBlockchain" {
            let blockchainVC = segue.destination as! ViewInBlockchainViewController
            blockchainVC.presenter.txId = presenter.histObj.txId
        }
    }
    
}
