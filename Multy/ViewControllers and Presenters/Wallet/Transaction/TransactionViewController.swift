//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = TransactionViewController

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
        
        
        let tapOnTo = UITapGestureRecognizer(target: self, action: #selector(tapOnToAddress))
        walletToAddressLbl.isUserInteractionEnabled = true
        walletToAddressLbl.addGestureRecognizer(tapOnTo)
        
        let tapOnFrom = UITapGestureRecognizer(target: self, action: #selector(tapOnFromAddress))
        walletFromAddressLbl.isUserInteractionEnabled = true
        walletFromAddressLbl.addGestureRecognizer(tapOnFrom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
    }
    
    @objc func tapOnToAddress(recog: UITapGestureRecognizer) {
        tapFunction(recog: recog, labelFor: walletToAddressLbl)
    }
    
    @objc func tapOnFromAddress(recog: UITapGestureRecognizer) {
        tapFunction(recog: recog, labelFor: walletFromAddressLbl)
    }

    func tapFunction(recog: UITapGestureRecognizer, labelFor: UILabel) {
        let tapLocation = recog.location(in: labelFor)
        var lineNumber = Double(tapLocation.y / 16.5)
        lineNumber.round(.towardZero)
        var title = ""
        if labelFor == walletFromAddressLbl {
            title = presenter.histObj.txInputs[Int(lineNumber)].address
        } else { // if walletToAddressLbl
            title = presenter.histObj.txOutputs[Int(lineNumber)].address
        }
        
        let actionSheet = UIAlertController(title: "", message: title, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: localize(string: Constants.cancelString), style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: localize(string: Constants.copyToClipboardString), style: .default, handler: { (action) in
            UIPasteboard.general.string = title
        }))
        actionSheet.addAction(UIAlertAction(title: localize(string: Constants.shareString), style: .default, handler: { (action) in
            let objectsToShare = [title]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                } else {
                    if let appName = activityType?.rawValue {
                        //                        self.sendAnalyticsEvent(screenName: "\(screenWalletWithChain)\(self.wallet!.chain)", eventName: "\(shareToAppWithChainTap)\(self.wallet!.chain)_\(appName)")
                    }
                }
            }
            activityVC.setPresentedShareDialogToDelegate()
            self.present(activityVC, animated: true, completion: nil)
        }))
        self.present(actionSheet, animated: true, completion: nil)
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
            self.titleLbl.text = localize(string: Constants.transactionInfoString)
        } else {                        // SEND
            self.makeBackColor(color: self.presenter.sendBackColor)
            self.titleLbl.text = localize(string: Constants.transactionInfoString)
            self.transactionImg.image = #imageLiteral(resourceName: "sendBigIcon")
        }
    }
    
    func updateUI() {
        //        BTC
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm, d MMMM yyyy"
        let cryptoSumInBTC = UInt64(truncating: presenter.histObj.txOutAmount).btcValue
        
        switch self.presenter.wallet.blockchainType.blockchain {
        case BLOCKCHAIN_BITCOIN:
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
                self.sumInFiatLbl.text = "+\((cryptoSumInBTC * presenter.histObj.fiatCourseExchange).fixedFraction(digits: 2)) USD"
            } else {
                let outgoingAmount = presenter.wallet.outgoingAmount(for: presenter.histObj).btcValue
                self.transctionSumLbl.text = "-\(outgoingAmount.fixedFraction(digits: 8))"
                self.sumInFiatLbl.text = "-\((outgoingAmount * presenter.histObj.fiatCourseExchange).fixedFraction(digits: 2)) USD"
                
                if let donationAddress = arrOfOutputsAddresses.getDonationAddress(blockchainType: presenter.blockchainType) {
                    let donatOutPutObj = presenter.histObj.getDonationTxOutput(address: donationAddress)
                    if donatOutPutObj == nil {
                        return
                    }
                    let btcDonation = (donatOutPutObj?.amount as! UInt64).btcValue
                    self.donationView.isHidden = false
                    self.constraintDonationHeight.constant = makeDonationConstraint()
                    self.donationCryptoSum.text = btcDonation.fixedFraction(digits: 8)
                    self.donationCryptoName.text = " BTC"
                    self.donationFiatSumAndName.text = "\((btcDonation * presenter.histObj.fiatCourseExchange).fixedFraction(digits: 2)) USD"
                }
            }
        case BLOCKCHAIN_ETHEREUM:
            if presenter.histObj.txStatus.intValue == TxStatus.MempoolIncoming.rawValue ||
                presenter.histObj.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
                self.dateLbl.text = dateFormatter.string(from: presenter.histObj.blockTime)
            } else {
                self.dateLbl.text = dateFormatter.string(from: presenter.histObj.blockTime)
            }
            self.noteLbl.text = "" // NOTE FROM HIST OBJ
            self.constraintNoteFiatSum.constant = 10
            
            self.transactionCurencyLbl.text = "ETH"     // check currencyID
            self.walletFromAddressLbl.text = presenter.histObj.addressesArray.first
            self.personNameLbl.text = ""   // before we don`t have address book    OR    Wallet Name
            
            self.walletToAddressLbl.text = presenter.histObj.addressesArray.last
            self.numberOfConfirmationLbl.text = makeConfirmationText()
            self.blockchainImg.image = UIImage(named: presenter.blockchainType.iconString)
            if isIncoming {
                let fiatAmountInWei = BigInt(presenter.histObj.txOutAmountString) * presenter.histObj.fiatCourseExchange
                self.transctionSumLbl.text = "+" + BigInt(presenter.histObj.txOutAmountString).cryptoValueString(for: BLOCKCHAIN_ETHEREUM)
                self.sumInFiatLbl.text = "+" + fiatAmountInWei.fiatValueString(for: BLOCKCHAIN_ETHEREUM) + " USD"
            } else {
                let fiatAmountInWei = BigInt(presenter.histObj.txOutAmountString) * presenter.histObj.fiatCourseExchange
                self.transctionSumLbl.text = "-" + BigInt(presenter.histObj.txOutAmountString).cryptoValueString(for: BLOCKCHAIN_ETHEREUM)
                self.sumInFiatLbl.text = "-" + fiatAmountInWei.fiatValueString(for: BLOCKCHAIN_ETHEREUM) + " USD"
                
            }
        default: break
        }
    }
    
    func makeDonationConstraint() -> CGFloat {
        var const: CGFloat = 0
        switch screenHeight {
        case heightOfFive: const = 323
        default: const = 283
        }
        return const
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
            textForConfirmations = "1 \(localize(string: Constants.confirmationString))"
        default: // not 1
            textForConfirmations = "\(presenter.histObj.confirmations) \(localize(string: Constants.confirmationsString))"
        }
        
        return textForConfirmations
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewInBlockchain" {
            let blockchainVC = segue.destination as! ViewInBlockchainViewController
            blockchainVC.presenter.txId = presenter.histObj.txId
            blockchainVC.presenter.blockchainType = presenter.blockchainType
            blockchainVC.presenter.blockchain = presenter.blockchain
            blockchainVC.presenter.txHash = presenter.histObj.txHash
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Wallets"
    }
}
