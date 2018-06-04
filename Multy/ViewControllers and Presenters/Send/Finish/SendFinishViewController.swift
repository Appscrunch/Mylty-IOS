//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = SendFinishViewController

class SendFinishViewController: UIViewController, UITextFieldDelegate, AnalyticsProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middle: UIView!
    @IBOutlet weak var bottom: UIView!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var cryptoSumLbl: UILabel!
    @IBOutlet weak var cryptoNamelbl: UILabel!
    @IBOutlet weak var fiatSumAndCurrancyLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var noteTF: UITextField!
    
    @IBOutlet weak var walletNameLbl: UILabel!
//    @IBOutlet weak var walletCryptoSumAndCurrencyLbl: UILabel!
    @IBOutlet weak var walletFiatSumAndCurrencyLbl: UILabel!
    @IBOutlet weak var walletsAddressesLbl: UILabel!
    
    @IBOutlet weak var transactionSpeedNameLbl: UILabel!
//    @IBOutlet weak var transactionSpeedTimeLbl: UILabel!
    @IBOutlet weak var transactionFeeCostLbl: UILabel! // exp: 0.002 BTC / 1.54 USD
    
    
    @IBOutlet weak var arr1: UIImageView!
    @IBOutlet weak var arr2: UIImageView!
    @IBOutlet weak var arr3: UIImageView!
    @IBOutlet var arrCollection: [UIImageView]!
    
    @IBOutlet weak var btnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideLabel: UILabel!
    @IBOutlet weak var slideColorView: UIView!
    
    let presenter = SendFinishPresenter()
    var imageArr = [#imageLiteral(resourceName: "slideToSend1"),#imageLiteral(resourceName: "slideToSend2"),#imageLiteral(resourceName: "slideToSend3")]
    var timer: Timer?
    
    var startSlideX: CGFloat = 0.0
    var finishSlideX: CGFloat = screenWidth - 33
    var isAnimateEnded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
//        self.fixUIForX()
        self.presenter.sendFinishVC = self
        self.hideKeyboardWhenTappedAround()
        self.presenter.makeEndSum()

        self.noteTF.delegate = self
        
        self.setupUI()
        sendAnalyticsEvent(screenName: "\(screenSendSummaryWithChain)\(presenter.transactionDTO.choosenWallet!.chain)",
                            eventName: "\(screenSendSummaryWithChain)\(presenter.transactionDTO.choosenWallet!.chain)")
    }
    
    override func viewDidLayoutSubviews() {
        slideColorView.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                   UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                     gradientOrientation: .horizontal)
        
        if screenHeight == heightOfX {
            if slideColorView.frame.width == screenWidth && slideColorView.frame.maxY < screenHeight - 80 {
                btnTopConstraint.constant = btnTopConstraint.constant + (screenHeight - slideColorView.frame.maxY - 80)
            }
        } else {
            if slideColorView.frame.width == screenWidth && slideColorView.frame.maxY < screenHeight - 20 {
                btnTopConstraint.constant = btnTopConstraint.constant + (screenHeight - slideColorView.frame.maxY - 20)
            }
        }
    }
    
    func setupUI() {
        let shadowColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5)
        topView.setShadow(with: shadowColor)
        middle.setShadow(with: shadowColor)
        bottom.setShadow(with: shadowColor)
        cryptoImage.image = UIImage(named: presenter.transactionDTO.blockchainType!.iconString)
        
        cryptoSumLbl.text = presenter.sumInCryptoString
        cryptoNamelbl.text = presenter.cryptoName
        fiatSumAndCurrancyLbl.text = "\(presenter.sumInFiatString) \(presenter.fiatName)"
        addressLbl.text = presenter.transactionDTO.sendAddress
        walletNameLbl.text = presenter.transactionDTO.choosenWallet?.name
        
        
        walletsAddressesLbl.text = presenter.transactionDTO.choosenWallet!.stringAddressesWithSpendableOutputs()
        let fiatSum = presenter.transactionDTO.choosenWallet!.sumInFiatString
        walletFiatSumAndCurrencyLbl.text = "\(presenter.transactionDTO.choosenWallet!.sumInCryptoString) \(presenter.transactionDTO.choosenWallet!.cryptoName)" + " / " + "\(fiatSum) \(presenter.transactionDTO.choosenWallet!.fiatName)"
        transactionFeeCostLbl.text = "\(presenter.feeAmountInCryptoString) \(presenter.cryptoName)/\(presenter.feeAmountInFiatString) \(presenter.fiatName)"
        transactionSpeedNameLbl.text = "\(presenter.transactionDTO.transaction?.transactionRLM?.speedName ?? "") "
//        transactionSpeedTimeLbl.text =  "\(presenter.transactionDTO.transaction?.transactionRLM?.speedTimeString ?? "")"
//        if view.frame.height == 736 {
//            btnTopConstraint.constant = 105
//        }
        
        animate()
        
        startSlideX = slideView.frame.origin.x
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(slideToSend))
        slideView.isUserInteractionEnabled = true
        slideView.addGestureRecognizer(gestureRecognizer)
        
        let tapOnTo = UITapGestureRecognizer(target: self, action: #selector(tapOnToAddress))
        addressLbl.isUserInteractionEnabled = true
        addressLbl.addGestureRecognizer(tapOnTo)
        
        let tapOnFrom = UITapGestureRecognizer(target: self, action: #selector(tapOnFromAddress))
        walletsAddressesLbl.isUserInteractionEnabled = true
        walletsAddressesLbl.addGestureRecognizer(tapOnFrom)
    }
    
    @objc func tapOnToAddress(recog: UITapGestureRecognizer) {
        tapFunction(recog: recog, labelFor: addressLbl)
    }
    
    @objc func tapOnFromAddress(recog: UITapGestureRecognizer) {
        tapFunction(recog: recog, labelFor: walletsAddressesLbl)
    }
    
    func tapFunction(recog: UITapGestureRecognizer, labelFor: UILabel) {
        let tapLocation = recog.location(in: labelFor)
        var lineNumber = Double(tapLocation.y / 16.5)
        lineNumber.round(.towardZero)
        var title = ""
        if labelFor == walletsAddressesLbl {
            title = presenter.transactionDTO.choosenWallet!.addressesWithSpendableOutputs()[Int(lineNumber)]
        } else { // if walletToAddressLbl
            title = presenter.transactionDTO.sendAddress!
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
    
    @IBAction func slideToSend(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        if isAnimateEnded {
            return
        }
        if slideView.frame.maxX + translation.x >= finishSlideX {
            UIView.animate(withDuration: 0.3) {
                self.isAnimateEnded = true
                self.slideView.frame.origin.x = self.finishSlideX - self.slideView.frame.width
//                self.view.isUserInteractionEnabled = false
                self.nextAction(Any.self)
            }
            return
        }
        
        gestureRecognizer.view!.center = CGPoint(x: slideView.center.x + translation.x, y: slideView.center.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        
        if gestureRecognizer.view!.frame.maxX < screenWidth / 2 {
            UIView.animate(withDuration: 0.3) {
                self.slideLabel.alpha = 0.5
            }
        } else if gestureRecognizer.view!.frame.maxX > screenWidth / 2 {
            UIView.animate(withDuration: 0.3) {
                self.slideLabel.alpha = 0
            }
        }
        
        if gestureRecognizer.state == .ended {
            if gestureRecognizer.view!.frame.origin.x < screenWidth - 100 {
                slideToStart()
            }
        }
    }
    
    func slideToStart() {
        UIView.animate(withDuration: 0.3) {
            self.slideView.frame.origin.x = self.startSlideX
            self.slideLabel.alpha = 1.0
            self.isAnimateEnded = false
        }
    }
    
    
    func animate() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.decrease), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc func decrease() {
        if self.arr1.image == imageArr[0]  {
            UIView.transition(with: self.arrCollection[0], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr1.image = self.imageArr[2] }, completion: nil)
            UIView.transition(with: self.arrCollection[1], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr2.image = self.imageArr[0] }, completion: nil)
            UIView.transition(with: self.arrCollection[2], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr3.image = self.imageArr[1] }, completion: nil)
        } else if self.arr1.image == imageArr[2] {
            UIView.transition(with: self.arrCollection[0], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr1.image = self.imageArr[1] }, completion: nil)
            UIView.transition(with: self.arrCollection[1], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr2.image = self.imageArr[2] }, completion: nil)
            UIView.transition(with: self.arrCollection[2], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr3.image = self.imageArr[0] }, completion: nil)
        } else if self.arr1.image == imageArr[1] {
            UIView.transition(with: self.arrCollection[0], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr1.image = self.imageArr[0] }, completion: nil)
            UIView.transition(with: self.arrCollection[1], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr2.image = self.imageArr[1] }, completion: nil)
            UIView.transition(with: self.arrCollection[2], duration: 0.1, options: .transitionCrossDissolve, animations: { self.arr3.image = self.imageArr[2] }, completion: nil)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: "\(screenSendSummaryWithChain)\(presenter.transactionDTO.choosenWallet!.chain)", eventName: closeTap)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func addNoteAction(_ sender: Any) {
        sendAnalyticsEvent(screenName: "\(screenSendSummaryWithChain)\(presenter.transactionDTO.choosenWallet!.chain)", eventName: addNoteTap)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.createRecentAddress()
        let wallet = presenter.transactionDTO.choosenWallet!
        let newAddress = wallet.shouldCreateNewAddressAfterTransaction ? presenter.transactionDTO.transaction!.newChangeAddress! : ""
        
        let newAddressParams = [
            "walletindex"   : wallet.walletID.intValue,
            "address"       : newAddress,
            "addressindex"  : wallet.addresses.count,
            "transaction"   : presenter.transactionDTO.transaction!.rawTransaction!,
            "ishd"          : NSNumber(booleanLiteral: wallet.shouldCreateNewAddressAfterTransaction)
            ] as [String : Any]
        
        let params = [
            "currencyid": wallet.chain,
            "networkid" : wallet.chainType,
            "payload"   : newAddressParams
            ] as [String : Any]
        
        DataManager.shared.sendHDTransaction(transactionParameters: params) { (dict, error) in
            print("---------\(dict)")
            
            if error != nil {
                self.presentAlert()
                print("sendHDTransaction Error: \(error)")
                self.slideToStart()
                self.view.isUserInteractionEnabled = true
                self.sendAnalyticsEvent(screenName: "\(screenSendAmountWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: transactionErrorFromServer)
                return
            }
            
            if dict!["code"] as! Int == 200 {
                self.performSegue(withIdentifier: "sendingAnimationVC", sender: sender)
            } else {
                self.sendAnalyticsEvent(screenName: "\(screenSendAmountWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: transactionErrorFromServer)
                self.presentAlert()
            }
        }
    }

    func createRecentAddress() {
        RealmManager.shared.writeOrUpdateRecentAddress(blockchainType: presenter.transactionDTO.blockchainType!,
                                                       address: presenter.transactionDTO.sendAddress!,
                                                       date: Date())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func presentAlert() {
        let message = localize(string: Constants.errorSendingTxString)
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func fixUIForX() {
//        if screenHeight == heightOfX {
//            self.btnTopConstraint.constant = 100
//        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendingAnimationVC" {
            let sendAnimationVC = segue.destination as! SendingAnimationViewController
            sendAnimationVC.chainId = presenter.transactionDTO.choosenWallet!.chain as? Int
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
