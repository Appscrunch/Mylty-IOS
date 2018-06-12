//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = DonationSendViewController

class DonationSendViewController: UIViewController, UITextFieldDelegate, AnalyticsProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var walletCryptoBtn: UIButton!
    @IBOutlet weak var walletFiatLbl: UILabel!
    
    @IBOutlet weak var donationTF: UITextField!
    @IBOutlet weak var fiatDonationLbl: UILabel!
    @IBOutlet weak var donatView: UIView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var botView: UIView!
    
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonContraint: NSLayoutConstraint!
    
    
    let presenter = DonationSendPresenter()
    var isCustom = false
    
    var isCanDonat = false
    
    var countSymbolsAfterComma = 0
    
//    let progressHud = ProgressHUD(text: "Sending...")
    let loader = PreloaderView(frame: HUDFrame, text: "Sending", image: #imageLiteral(resourceName: "walletHuge"))
    
    var isTransactionSelected = false
    var isDefaultValueSet = false
    
    var selectedTabIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        loader.setupUI(text: localize(string: Constants.sendingString), image: #imageLiteral(resourceName: "walletHuge"))
        self.view.addSubview(loader)
        self.hideKeyboardWhenTappedAround()
        self.presenter.mainVC = self
        self.registerCells()
        
        self.presenter.getWallets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissKeyboard), name: Notification.Name("hideKeyboard"), object: nil)
        
        sendDonationScreenPresentedAnalytics()
        
        presenter.getAddress()
        topView.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 1, alpha: 0.5))
        botView.setShadow(with: #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 1, alpha: 0.5))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerNotificationFromKeyboard()
        
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isDefaultValueSet = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardNotification()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //update send button constraint
        scrollView.contentInset = .zero
        
        
        
        if screenHeight == heightOfX {
            sendButtonContraint.constant = 140
        } else if screenHeight > scrollView.contentSize.height + 20 && scrollView.contentSize.height > 0 {
            sendButtonContraint.constant = 30 + (screenHeight - scrollView.contentSize.height - 20)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func registerCells() {
        let transactionCell = UINib(nibName: "TransactionFeeTableViewCell", bundle: nil)
        self.tableView.register(transactionCell, forCellReuseIdentifier: "transactionCell")
        
        let customFeeCell = UINib(nibName: "CustomTrasanctionFeeTableViewCell", bundle: nil)
        self.tableView.register(customFeeCell, forCellReuseIdentifier: "customFeeCell")
    }
    
    @IBAction func sendAction(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        self.loader.show(customTitle: localize(string: Constants.sendingString))
        self.presenter.createAndSendTransaction()
        sendDonationScreenPressSendAnalytics()
    }
    
    func updateUIWithWallet() {
        let exchangeCourse = presenter.walletPayFrom!.exchangeCourse
        let cryptoStr = "\(self.presenter.walletPayFrom?.sumInCrypto.fixedFraction(digits: 8) ?? "0.0") \(self.presenter.walletPayFrom?.cryptoName ?? "BTC")"
        let fiatSum = "\(((self.presenter.walletPayFrom?.sumInCrypto)! * exchangeCourse).fixedFraction(digits: 2)) \(self.presenter.walletPayFrom?.fiatName ?? "USD")"
        
        let percentFromSum = 0.03
        var sumForDonat = ((self.presenter.walletPayFrom?.sumInCrypto)! * percentFromSum)
        if sumForDonat.satoshiValue < minSatoshiToDonate {
            sumForDonat = minSatoshiToDonate.btcValue
        }
        let fiatDonation = sumForDonat * exchangeCourse
        
        self.walletNameLbl.text = self.presenter.walletPayFrom?.name
        self.walletCryptoBtn.setTitle(cryptoStr, for: .normal)
        self.walletFiatLbl.text = fiatSum
        
        self.donationTF.text = sumForDonat.fixedFraction(digits: 8)
        self.fiatDonationLbl.text = "\(fiatDonation.fixedFraction(digits: 2)) USD"
    }
    
    //MARK: Keyboard to scrollview
    func registerNotificationFromKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetailsViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetailsViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotification() {
//        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
//                let bottOffset = CGPoint(x: 0.0, y: self.scrollView.contentSize.height - scrollView.bounds.size.height)
//                self.scrollView.setContentOffset(bottOffset, animated: true)
//                self.view.frame.origin.y -= keyboardSize.height/4
                self.tableView.isUserInteractionEnabled = false
                if screenHeight == heightOfX {
                    self.view.frame.origin.y -= keyboardSize.height/4
                } else {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.tableView.isUserInteractionEnabled = true
                self.makeSendAvailable(isAvailable: true)
                if screenHeight == heightOfX {
                    self.view.frame.origin.y += keyboardSize.height/4
                } else {
                    self.view.frame.origin.y += keyboardSize.height
                }
            }
        }
    }
    //end
    
    @IBAction func chooseAnoterWalletAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Receive", bundle: nil)
        let walletsVC = storyboard.instantiateViewController(withIdentifier: "ReceiveStart") as! ReceiveStartViewController
        walletsVC.presenter.isNeedToPop = true
        walletsVC.sendWalletDelegate = self.presenter
        walletsVC.titleTextKey = "Send Donation From"
        walletsVC.whereFrom = self
        walletsVC.presenter.walletsArr = presenter.btcWallets
        self.navigationController?.pushViewController(walletsVC, animated: true)
    }
    
    func makeSendAvailable(isAvailable: Bool) {
        var isAvailable = isAvailable
        let donatAmount = self.donationTF.text?.convertStringWithCommaToDouble()
        if donatAmount! > 0.0 {
        } else {
            isAvailable = false
            shakeView(viewForShake: donatView)
        }
        if isAvailable && isTransactionSelected {
            self.sendBtn.isUserInteractionEnabled = true
            self.sendBtn.backgroundColor = #colorLiteral(red: 0.009615149349, green: 0.5124486089, blue: 0.9994245172, alpha: 1)
        } else {
            self.sendBtn.isUserInteractionEnabled = false
            self.sendBtn.backgroundColor = #colorLiteral(red: 0.8196047544, green: 0.8196094632, blue: 0.8390848637, alpha: 1)
        }
    }
    
    func presentWarning(message: String) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "." || string == ",") && ((self.donationTF.text?.contains(","))! || (self.donationTF.text?.contains("."))!){
            return false
        }
        
        if let textString = textField.text {
            if textString == "0" && string != "," && string != "." && !string.isEmpty {
                return false
            }
        }
        
        if string == "." {
            self.donationTF.text?.append(",")
            return false
        }
        
        if (self.donationTF.text?.contains(","))! && string != "" {
            let strAfterDot: [String?] = (self.donationTF.text?.components(separatedBy: ","))!
            if strAfterDot[1]?.count == 8 {
                return false
            }
        }
        
        if (self.donationTF.text! + string).convertStringWithCommaToDouble() > self.presenter.maxAvailable {
            self.presentWarning(message: localize(string: Constants.moreThenYouHaveString))
            return false
        }
        
        if string == "" {
            self.donationTF.text?.removeLast()
            self.presenter.makeFiatDonat()
            return false
        }
        
        self.donationTF.text?.append(string) // = return true
        self.presenter.makeFiatDonat()
        return false
    }
    
}

extension DonationSendViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 2 {
            let transactionCell = self.tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionFeeTableViewCell
            transactionCell.feeRate = self.presenter.feeRate
            // FIXME: add blocchains type (transactionDTO.blockchainType)
            transactionCell.blockchainType = BlockchainType.create(currencyID: 0, netType: 0)  // only BTC!!
            if indexPath.row == 0 {
                transactionCell.makeCellBy(indexPath: [0, 3])  //Slow
                
                //set default 
                if !isDefaultValueSet {
                    transactionCell.checkMarkImage.isHidden = false
                    
                    self.isTransactionSelected = true
                    makeSendAvailable(isAvailable: isTransactionSelected)
                    self.presenter.selectedIndexOfSpeed = indexPath.row
                }
            } else { //indexPath.row = 1
                transactionCell.makeCellBy(indexPath: [0, 2])  //Medium
            }
            
            return transactionCell
        } else {
            let customFeeCell = self.tableView.dequeueReusableCell(withIdentifier: "customFeeCell") as! CustomTrasanctionFeeTableViewCell
            
            return customFeeCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch indexPath.row {
//        case 0:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: veryFastTap)
//        case 1:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: fastTap)
//        case 2:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: mediumTap)
//        case 3:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: slowTap)
//        case 4:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: verySlowTap)
//        case 5:
//            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: customTap)
//        default : break
//        }
        
        if indexPath.row != 2 {
            if self.isCustom {
                let customCell = self.tableView.cellForRow(at: [0,2]) as! CustomTrasanctionFeeTableViewCell
                customCell.reloadUI()
            }
            var cells = self.tableView.visibleCells
            
            cells.removeLast()

            let trueCells = cells as! [TransactionFeeTableViewCell]
            if trueCells[indexPath.row].checkMarkImage.isHidden == false {
                trueCells[indexPath.row].checkMarkImage.isHidden = true
                self.presenter.selectedIndexOfSpeed = nil
                self.isTransactionSelected = false
                makeSendAvailable(isAvailable: isTransactionSelected)
                
                return
            }
            for cell in trueCells {
                cell.checkMarkImage.isHidden = true
            }
            self.isTransactionSelected = true
            makeSendAvailable(isAvailable: isTransactionSelected)
            trueCells[indexPath.row].checkMarkImage.isHidden = false
            self.presenter.selectedIndexOfSpeed = indexPath.row
        } else {
            self.removeKeyboardNotification()
            self.isCustom = true
            let storyboard = UIStoryboard(name: "Send", bundle: nil)
            let customVC = storyboard.instantiateViewController(withIdentifier: "customVC") as! CustomFeeViewController
//            customVC.presenter.chainId = self.presenter.transactionDTO.choosenWallet!.chain
            customVC.presenter.blockchainType = BlockchainType(blockchain: BLOCKCHAIN_BITCOIN, net_type: 0)
            customVC.delegate = self.presenter
            customVC.rate = Int(self.presenter.customFee)
            self.presenter.selectedIndexOfSpeed = indexPath.row
            self.navigationController?.pushViewController(customVC, animated: true)
            
            var cells = self.tableView.visibleCells
            cells.removeLast()
            let trueCells = cells as! [TransactionFeeTableViewCell]
            for cell in trueCells {
                cell.checkMarkImage.isHidden = true
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
