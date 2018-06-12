//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton
import Lottie

private typealias LocalizeDelegate = SendStartViewController

class SendStartViewController: UIViewController, UITextViewDelegate, AnalyticsProtocol, DonationProtocol, CancelProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: ZFRippleButton!
    @IBOutlet weak var middleConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressInTfLlb: UILabel!
    @IBOutlet weak var addressTV: UITextView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var botView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var noAddressLbl: UILabel!
    @IBOutlet weak var recentAddresses: UILabel!
    @IBOutlet weak var magicalSendImageView: UIImageView!
    var magicSendAnimationView : LOTAnimationView?
    @IBOutlet weak var magicalSendButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var qrScanButton: UIButton!
    
    let presenter = SendStartPresenter()
    var stingIdForInApp = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        self.presenter.sendStartVC = self
        sendAnalyticsEvent(screenName: screenSendTo, eventName: screenSendTo)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        (self.tabBarController as! CustomTabBarViewController).menuButton.isHidden = true
        (self.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: true)
//        if self.presenter.addressSendTo != "" {
//            self.modifyNextButtonMode()
//        }
    }
    
    func hideKeyboardWhenTappedAroundForSendStart() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSendKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func setupUI() {
        registerCells()
        ipadFix()
        presenter.getAddresses()
        hideKeyboardWhenTappedAroundForSendStart()
        nextBtn.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1.0)
        setupShadow()
        addressTV.delegate = self
        if presenter.transactionDTO.sendAddress != nil && !presenter.transactionDTO.sendAddress!.isEmpty {
            addressTV.text = presenter.transactionDTO.sendAddress!
            placeholderLabel.isHidden = !addressTV.text.isEmpty
        }
        magicalSendButton.layer.cornerRadius = 12
        magicalSendButton.backgroundColor = #colorLiteral(red: 0.01176470588, green: 0.4901960784, blue: 1, alpha: 1)
        magicalSendButton.layer.shadowColor = #colorLiteral(red: 0.01176470588, green: 0.4901960784, blue: 1, alpha: 1).cgColor
        magicalSendButton.layer.shadowOpacity = 0.6
        magicalSendButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        magicalSendButton.layer.shadowRadius = 8
        
        qrScanButton.layer.cornerRadius = 12
        qrScanButton.layer.shadowColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.3).cgColor
        qrScanButton.layer.shadowOpacity = 1
        qrScanButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        qrScanButton.layer.shadowRadius = 8
        
        contactsButton.layer.cornerRadius = 12
        contactsButton.layer.shadowColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.3).cgColor
        contactsButton.layer.shadowOpacity = 1
        contactsButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        contactsButton.layer.shadowRadius = 8
        
    }
    
    @objc func dismissSendKeyboard(gesture: UITapGestureRecognizer) {
        presenter.transactionDTO.sendAddress = addressTV.text
        
        if presenter.transactionDTO.choosenWallet != nil && presenter.isTappedDisabledNextButton(gesture: gesture) {
            let isValidDTO = DataManager.shared.isAddressValid(address: presenter.transactionDTO.sendAddress!, for: presenter.transactionDTO.choosenWallet!)
            
            if !isValidDTO.isValid {
                let message = localize(string: Constants.notValidAddressString)
                presenter.presentAlert(message: message)
            }
            
            return
        }
        
        if !checkTVisEmpty() {
            modifyNextButtonMode()
        }
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NewWalletTableViewCell
        topCell?.makeTopCorners()
        
        if presenter.transactionDTO.sendAddress != nil && !presenter.transactionDTO.sendAddress!.isEmpty {
            self.modifyNextButtonMode()
        }
        
        if magicSendAnimationView == nil {
            magicSendAnimationView = LOTAnimationView(name: "magicSend")
            magicSendAnimationView!.frame = magicalSendImageView.bounds
            magicalSendImageView.insertSubview(magicSendAnimationView!, at: 0)
            magicalSendImageView.transform = CGAffineTransform(scaleX: 2, y: 2)
            magicSendAnimationView!.animationSpeed = 1.3
            magicSendAnimationView!.loopAnimation = true
            magicSendAnimationView!.play()
        } else {
            if !magicSendAnimationView!.isAnimationPlaying {
                magicSendAnimationView!.play()
            }
        }
        
        fixUI()
    }
    
    
    
    func registerCells() {
        let searchAddressCell = UINib(nibName: "SearchAddressTableViewCell", bundle: nil)
        self.tableView.register(searchAddressCell, forCellReuseIdentifier: "searchAddressCell")
        
        let oneLabelCell = UINib(nibName: "NewWalletTableViewCell", bundle: nil)
        self.tableView.register(oneLabelCell, forCellReuseIdentifier: "oneLabelCell")
        
        let recentCell = UINib(nibName: "RecentAddressTableViewCell", bundle: nil)
        self.tableView.register(recentCell, forCellReuseIdentifier: "recentCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.presenter.cancelAction()
    }
    
    
    @IBAction func nextAction(_ sender: Any) {
        if self.presenter.transactionDTO.choosenWallet == nil {
            self.performSegue(withIdentifier: "chooseWalletVC", sender: sender)
        } else {
            self.performSegue(withIdentifier: presenter.destinationSegueString(), sender: sender)
        }
    }
    
    func modifyNextButtonMode() {
//        if presenter.transactionDTO.sendAddress != nil && presenter.isValidCryptoAddress() {
            if !nextBtn.isEnabled {
                self.nextBtn.isEnabled = true
                self.nextBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                         UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                           gradientOrientation: .horizontal)
            }
    }
    
    @IBAction func scanQrAction(_ sender: Any) {
        performSegue(withIdentifier: "qrCamera", sender: Any.self)
        sendAnalyticsEvent(screenName: screenSendTo, eventName: scanQrTap)
    }
    
    @IBAction func wirelessScanAction(_ sender: Any) {
        
    }
    
    @IBAction func addressBookAction(_ sender: Any) {
//        unowned let weakSelf =  self
//        self.presentDonationAlertVC(from: weakSelf, with: "io.multy.addingContacts50")
        self.donate(idOfInApp: "io.multy.addingContacts50")
        sendDonationAlertScreenPresentedAnalytics(code: donationForContactSC)
    }
    
    
    func setupShadow() {
        let myColor = #colorLiteral(red: 0.6509803922, green: 0.6941176471, blue: 0.7764705882, alpha: 0.3)
        topView.setShadow(with: myColor)
        botView.setShadow(with: myColor)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "chooseWalletVC"?:
            let chooseWalletVC = segue.destination as! WalletChooseViewController
            chooseWalletVC.presenter.transactionDTO = presenter.transactionDTO
        case "qrCamera"?:
            let qrScanerVC = segue.destination as! QrScannerViewController
            qrScanerVC.qrDelegate = presenter
        case "sendBTCDetailsVC"?:
            let sendDetailsVC = segue.destination as! SendDetailsViewController
            sendDetailsVC.presenter.transactionDTO = presenter.transactionDTO
        case "sendETHDetailsVC"?:
            let sendDetailsVC = segue.destination as! EthSendDetailsViewController
            sendDetailsVC.presenter.transactionDTO = presenter.transactionDTO
        default:
            break
        }
    }
    
    
    func donate(idOfInApp: String) {
        unowned let weakSelf =  self
        self.presentDonationAlertVC(from: weakSelf, with: idOfInApp)
        if idOfInApp == "io.multy.addingContacts50" {
            stingIdForInApp = "io.multy.addingContacts5"
            return
        } else if idOfInApp == "io.multy.wirelessScan50" {
            stingIdForInApp = "io.multy.wirelessScan5"
            return
        }
        stingIdForInApp = idOfInApp

    }

    
    func cancelDonation() {
        self.makePurchaseFor(productId: stingIdForInApp)
    }
    
    func cancelAction() {
//        presentDonationVCorAlert()
        
        self.makePurchaseFor(productId: stingIdForInApp)
    }
    
    func donate50(idOfProduct: String) {
        self.makePurchaseFor(productId: idOfProduct)
    }
    
    func presentNoInternet() {
        
    }
    
    
    func fixUI() {
        if screenHeight == heightOfX {
            self.nextBtn.frame.origin = CGPoint(x: 0, y: 714)
        }
    }
    
    func setTextToTV(address: String) {
        addressTV.text = address
        addressTV.scrollRangeToVisible(NSMakeRange(addressTV.text.count - 1, 0))
        placeholderLabel.isHidden = true
    }
}

extension SendStartViewController:  UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfaddresses()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recentCell = self.tableView.dequeueReusableCell(withIdentifier: "recentCell") as! RecentAddressTableViewCell
        recentCell.fillingCell(recentAddress: presenter.recentAddresses[indexPath.row])
        return recentCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.transactionDTO.update(from: presenter.recentAddresses[indexPath.row].address)
        self.setTextToTV(address: presenter.recentAddresses[indexPath.row].address)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.modifyNextButtonMode()

    }
    
    func updateUI() {
        self.tableView.reloadData()
        noAddressLbl.isHidden = !self.presenter.recentAddresses.isEmpty
        recentAddresses.isHidden = self.presenter.recentAddresses.isEmpty
    }
    
    func ipadFix() {
        if screenHeight == heightOfiPad {
            self.middleConstraint.constant = 80
        }
    }
    
    func checkTVisEmpty() -> Bool {
        return addressTV.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.presenter.sendAddress(address: textView.text!)
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = !placeholderLabel.isHidden
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
