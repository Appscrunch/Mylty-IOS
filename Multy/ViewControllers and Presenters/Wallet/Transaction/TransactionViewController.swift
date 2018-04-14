//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class TransactionViewController: UIViewController, AnalyticsProtocol {

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
    
    var state = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        self.presenter.transctionVC = self
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.isIncoming = presenter.histObj.isIncoming()
        self.checkHeightForScrollAvailability()
        self.checkForSendOrReceive()
        self.constraintDonationHeight.constant = 0
        self.donationView.isHidden = true
        self.updateUI()
        self.sendAnalyticOnStrart()
    }

    func checkHeightForScrollAvailability() {
//        if screenHeight >= 667 {
//            self.scrollView.isScrollEnabled = false
//        }
    }
    
    func sendAnalyticOnStrart() {
        if self.presenter.blockedAmount(for: presenter.histObj) > 0 {
            state = 0
        } else {
            if isIncoming {
                state = -1
            } else {
                state = 1
            }
        }
        sendAnalyticsEvent(screenName: "\(screenTransactionWithChain)\(presenter.blockchainType.blockchain.rawValue)", eventName: "\(screenTransactionWithChain)\(presenter.blockchainType.blockchain.rawValue)_\(state)")
    }
    
    func checkForSendOrReceive() {
        if isIncoming {  // RECEIVE
            self.makeBackColor(color: self.presenter.receiveBackColor)
            self.titleLbl.text = "Transaction Info"
        } else {                        // SEND
            self.makeBackColor(color: self.presenter.sendBackColor)
            self.titleLbl.text = "Transaction Info"
            self.transactionImg.image = #imageLiteral(resourceName: "sendBigIcon")
        }
    }
    
    func updateUI() {
        //Receive
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, d MMMM yyyy"
        let cryptoSumInBTC = UInt64(truncating: presenter.histObj.txOutAmount).btcValue
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
        self.blockchainImg.image = UIImage(named: presenter.blockchainType.iconString)
        if isIncoming {
            self.transctionSumLbl.text = "+\(cryptoSumInBTC.fixedFraction(digits: 8))"
            self.sumInFiatLbl.text = "+\((cryptoSumInBTC * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
        } else {
            let outgoingAmount = presenter.wallet.outgoingAmount(for: presenter.histObj).btcValue
            self.transctionSumLbl.text = "-\(outgoingAmount.fixedFraction(digits: 8))"
            self.sumInFiatLbl.text = "-\((outgoingAmount * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
            
            if let donationAddress = arrOfOutputsAddresses.getDonationAddress(blockchainType: presenter.blockchainType) {
                let donatOutPutObj = presenter.histObj.getDonationTxOutput(address: donationAddress)
                if donatOutPutObj == nil {
                    return
                }
                let btcDonation = (donatOutPutObj?.amount as! UInt64).btcValue
                self.donationView.isHidden = false
                self.constraintDonationHeight.constant = 283
                self.donationCryptoSum.text = btcDonation.fixedFraction(digits: 8)
                self.donationCryptoName.text = " BTC"
                self.donationFiatSumAndName.text = "\((btcDonation * presenter.histObj.btcToUsd).fixedFraction(digits: 2)) USD"
            }
        }
    }
    
    func makeBackColor(color: UIColor) {
        self.backView.backgroundColor = color
        self.scrollView.backgroundColor = color
    }
    
    @IBAction func closeAction() {
        self.navigationController?.popViewController(animated: true)
        let blockchainTypeUInt32 = presenter.blockchainType.blockchain.rawValue
        sendAnalyticsEvent(screenName: "\(screenTransactionWithChain)\(blockchainTypeUInt32)", eventName: "\(closeWithChainTap)\(blockchainTypeUInt32)")
    }
    
    @IBAction func viewInBlockchainAction(_ sender: Any) {
        self.performSegue(withIdentifier: "viewInBlockchain", sender: nil)
        let blockchainTypeUInt32 = presenter.blockchainType.blockchain.rawValue
        sendAnalyticsEvent(screenName: "\(screenTransactionWithChain)\(blockchainTypeUInt32)", eventName: "\(viewInBlockchainWithTxStatus)\(blockchainTypeUInt32)_\(state)")
    }
    
    func makeConfirmationText() -> String {
        var textForConfirmations = ""
        switch presenter.histObj.confirmations {
        case 1:
            textForConfirmations = "1 Confirmation"
        default: // more than 6
            textForConfirmations = "\(presenter.histObj.confirmations) Confirmations"
        }
        
        return textForConfirmations
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewInBlockchain" {
            let blockchainVC = segue.destination as! ViewInBlockchainViewController
            blockchainVC.presenter.txId = presenter.histObj.txId
            blockchainVC.presenter.blockchainType = presenter.blockchainType
        }
    }
    
}
