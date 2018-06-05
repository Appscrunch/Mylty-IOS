//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

private typealias TableViewDelegate = SendDetailsViewController
private typealias TableViewDataSource = SendDetailsViewController
private typealias LocalizeDelegate = SendDetailsViewController

class SendDetailsViewController: UIViewController, UITextFieldDelegate, AnalyticsProtocol {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewForShadow: UIView!
    @IBOutlet weak var donationView: UIView!
    @IBOutlet weak var donationSeparatorView: UIView!
    @IBOutlet weak var donationTitleLbl: UILabel!
    @IBOutlet weak var donationTF: UITextField!
    @IBOutlet weak var donationFiatSumLbl: UILabel!
    @IBOutlet weak var donationFiatNameLbl: UILabel!
    @IBOutlet weak var donationCryptoNameLbl: UILabel!
    @IBOutlet weak var isDonateAvailableSW: UISwitch!
    
    @IBOutlet weak var constraintDonationHeight: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: ZFRippleButton!
    
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    
    
    let presenter = SendDetailsPresenter()
    
    var maxLengthForSum = 12
    
    var isCustom = false
//    let progressHUD = ProgressHUD(text: "Updating fee rates...")
    let loader = PreloaderView(frame: HUDFrame, text: "Updating rates", image: #imageLiteral(resourceName: "walletHuge"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loader)
        loader.show(customTitle: "Updating rates")
        self.swipeToBack()
        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.hideKeyboardWhenTappedAround()
        self.presenter.sendDetailsVC = self
        self.registerCells()
        self.registerNotificationFromKeyboard()
        self.setupShadow()
        self.setupDonationUI()
        
        if self.presenter.selectedIndexOfSpeed == nil {
            presenter.selectedIndexOfSpeed = 2
            tableView.reloadData()
//            self.tableView.selectRow(at: [0,2], animated: false, scrollPosition: .none)
//            self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: [0,2])
        }
        
        presenter.requestFee()
        
        presenter.getData()
        
        sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)")
        sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: donationEnableTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.nextBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                 UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                   gradientOrientation: .horizontal)
        
        let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TransactionFeeTableViewCell
        firstCell.setCornersForFirstCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.nullifyDonation()
        
        if screenHeight == heightOfX {
            bottomBtnConstraint.constant = 0
        }
    }
    
    func setupShadow() {
        let myColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.5)
        viewForShadow.setShadow(with: myColor)
        donationView.setShadow(with: myColor)
    }
    
    func setupDonationUI() {
        let exchangeCourse = presenter.transactionDTO.choosenWallet!.exchangeCourse
        self.donationTF.text = "\((self.presenter.donationInCrypto ?? 0.0).fixedFraction(digits: 8))"
        self.presenter.donationInFiat = self.presenter.donationInCrypto! * exchangeCourse
        self.donationFiatSumLbl.text = "\(self.presenter.donationInFiat?.fixedFraction(digits: 2) ?? "0.00")"
    }
    
    func registerCells() {
        let transactionCell = UINib(nibName: "TransactionFeeTableViewCell", bundle: nil)
        self.tableView.register(transactionCell, forCellReuseIdentifier: "transactionCell")
        
        let customFeeCell = UINib(nibName: "CustomTrasanctionFeeTableViewCell", bundle: nil)
        self.tableView.register(customFeeCell, forCellReuseIdentifier: "customFeeCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        presenter.transactionDTO.transaction!.donationDTO = nil
        presenter.transactionDTO.transaction!.transactionRLM = nil
        presenter.transactionDTO.transaction?.customFee = presenter.customFee
        
        navigationController?.popViewController(animated: true)
        sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(presenter.transactionDTO.choosenWallet!.chain)", eventName: closeTap)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.view.endEditing(true)
        
        if self.presenter.selectedIndexOfSpeed != nil {
            if isDonateAvailableSW.isOn {
                self.presenter.createDonation()
            }
            self.presenter.createTransaction(index: self.presenter.selectedIndexOfSpeed!)
            self.presenter.checkMaxAvailable()
        } else {
            let alert = UIAlertController(title: localize(string: Constants.pleaseChooseFeeRate), message: localize(string: Constants.predefinedValueMessageString), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: Keyboard to scrollview
    func registerNotificationFromKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetailsViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SendDetailsViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                if screenHeight == heightOfX {
                    bottomBtnConstraint.constant -= 35
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                if screenHeight == heightOfX {
                    bottomBtnConstraint.constant = 0
                }
            }
        }
    }
    //end
    
    //MARK: donationSwitch actions
    @IBAction func switchDonationAction(_ sender: Any) {
        var offset = scrollView.contentOffset
        let exchangeCourse = presenter.transactionDTO.choosenWallet!.exchangeCourse
        
        if !self.isDonateAvailableSW.isOn {
            self.donationTF.resignFirstResponder()
            self.presenter.donationInCrypto = 0.0
            self.presenter.donationInFiat = 0.0
            self.constraintDonationHeight.constant = self.constraintDonationHeight.constant / 2
            self.scrollView.contentSize.height = self.scrollView.contentSize.height - self.constraintDonationHeight.constant
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: donationDisabledTap)
        } else {
            self.donationTF.becomeFirstResponder()
            self.presenter.donationInCrypto = (self.donationTF.text! as NSString).doubleValue
            self.presenter.donationInFiat = self.presenter.donationInCrypto! * exchangeCourse
            self.constraintDonationHeight.constant = self.constraintDonationHeight.constant * 2
            self.scrollView.contentSize.height = self.scrollView.contentSize.height + self.constraintDonationHeight.constant
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: donationEnableTap)
        }
        self.hideOrShowDonationBottom()
//        self.scrollView.scrollRectToVisible(self.nextBtn.frame, animated: true)
        
        offset.y = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.size.height - 75
        if !self.isDonateAvailableSW.isOn {
            offset.y += 74
        }
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func hideOrShowDonationBottom() {
        self.donationSeparatorView.isHidden = !self.isDonateAvailableSW.isOn
        self.donationTF.isHidden = !self.isDonateAvailableSW.isOn
        self.donationFiatSumLbl.isHidden = !self.isDonateAvailableSW.isOn
        self.donationFiatNameLbl.isHidden = !self.isDonateAvailableSW.isOn
        self.donationCryptoNameLbl.isHidden = !self.isDonateAvailableSW.isOn
        self.donationTitleLbl.isHidden = !self.isDonateAvailableSW.isOn
    }
    //end
    
    //MARK: TextField delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.donationTF.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.isScrollEnabled = false
        self.scrollView.scrollRectToVisible(self.nextBtn.frame, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView.isScrollEnabled = true
    }
    
    func presentWarning(message: String) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string != "," || string != ".") && ((self.donationTF.text! + string) as NSString).doubleValue > presenter.transactionDTO.choosenWallet!.sumInCrypto {
            if string != "" {
                self.presentWarning(message: localize(string: Constants.moreThenYouHaveString))
                return false
            }
        }
        
        guard let text = textField.text else { return true }
        
        if text == "0" && string != "," && string != "." && !string.isEmpty {
            return false
        }
        
        let newLength = text.count + string.count - range.length

        if (string == "," || string == ".") && self.donationTF.text == "" {
            self.donationTF.text = "0\(string)"
        }
        
        if string == "" {
            self.donationTF.text?.removeLast()
            self.saveDonationSum(string: "")
            return false
        }
        
        if newLength <= self.maxLengthForSum {
            self.donationTF.text = self.donationTF.text?.replacingOccurrences(of: ",", with: ".")
            if string == "," && (self.donationTF.text?.contains("."))!{
                return false
            }
            if (self.donationTF.text?.contains("."))! && string != "" {
                let strAfterDot: [String?] = (self.donationTF.text?.components(separatedBy: "."))!
                if strAfterDot[1]?.count == 8 {
                    return false
                }
            }
            self.saveDonationSum(string: string)
        }
        sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: donationChanged)
        
        return newLength <= self.maxLengthForSum
    }
    
    func saveDonationSum(string: String) {
        let exchangeCourse = presenter.transactionDTO.choosenWallet!.exchangeCourse
        if string == "" && self.donationTF.text == "" {
            self.presenter.donationInCrypto = 0.0
            self.presenter.donationInFiat = 0.0
            self.donationFiatSumLbl.text = "\((self.presenter.donationInFiat ?? 0.0).fixedFraction(digits: 2))"
        } else {
            self.presenter.donationInCrypto = (self.donationTF.text! + string as NSString).doubleValue
            self.presenter.donationInFiat = self.presenter.donationInCrypto! * exchangeCourse
            self.presenter.donationInFiat = Double(round(100*self.presenter.donationInFiat!)/100)
            self.donationFiatSumLbl.text = "\((self.presenter.donationInFiat ?? 0.0).fixedFraction(digits: 2))"
        }
    }
    
    //end
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendEthVC" {
            let sendAmountVC = segue.destination as! SendAmountEthViewController
            
            presenter.transactionDTO.transaction!.donationDTO = presenter.donationObj
            presenter.transactionDTO.transaction!.transactionRLM = presenter.transactionObj
            presenter.transactionDTO.transaction!.customFee = presenter.customFee
            
            sendAmountVC.presenter.transactionDTO = presenter.transactionDTO
        }
    }
}

extension TableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: veryFastTap)
        case 1:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: fastTap)
        case 2:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: mediumTap)
        case 3:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: slowTap)
        case 4:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: verySlowTap)
        case 5:
            sendAnalyticsEvent(screenName: "\(screenTransactionFeeWithChain)\(self.presenter.transactionDTO.choosenWallet!.chain)", eventName: customTap)
        default : break
        }
        
        if indexPath.row != 5 {
            presenter.selectedIndexOfSpeed = indexPath.row
            presenter.updateCellsVisibility()
        } else {
            isCustom = true
            let storyboard = UIStoryboard(name: "Send", bundle: nil)
            let customVC = storyboard.instantiateViewController(withIdentifier: "customVC") as! CustomFeeViewController
            customVC.presenter.blockchainType = self.presenter.transactionDTO.choosenWallet!.blockchainType
            customVC.delegate = presenter
            customVC.rate = Int(presenter.customFee)
            customVC.previousSelected = presenter.selectedIndexOfSpeed
            presenter.selectedIndexOfSpeed = indexPath.row
            navigationController?.pushViewController(customVC, animated: true)
        }
    }
}

extension TableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != 5 {
            let transactionCell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TransactionFeeTableViewCell
            transactionCell.feeRate = presenter.feeRate
            transactionCell.blockchainType = self.presenter.transactionDTO.blockchainType
            transactionCell.makeCellBy(indexPath: indexPath)
            
            return transactionCell
        } else {
            let customFeeCell = tableView.dequeueReusableCell(withIdentifier: "customFeeCell") as! CustomTrasanctionFeeTableViewCell
            customFeeCell.blockchainType = presenter.transactionDTO.blockchainType
            customFeeCell.value = Int(presenter.customFee)
            customFeeCell.setupUI()

            return customFeeCell
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
