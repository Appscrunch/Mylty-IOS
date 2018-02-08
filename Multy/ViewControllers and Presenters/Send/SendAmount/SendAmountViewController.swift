//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

class SendAmountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel! // "Send \(crypyoName)"
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var topSumLbl: UILabel!
    @IBOutlet weak var topCurrencyNameLbl: UILabel!
    @IBOutlet weak var bottomSumLbl: UILabel!
    @IBOutlet weak var bottomCurrencyLbl: UILabel!
    @IBOutlet weak var spendableSumAndCurrencyLbl: UILabel!
    @IBOutlet weak var nextBtn: ZFRippleButton!
    @IBOutlet weak var maxBtn: UIButton!
    @IBOutlet weak var maxLbl: UILabel!
    @IBOutlet weak var btnSumLbl: UILabel!
    @IBOutlet weak var commissionSwitch: UISwitch!
    
    @IBOutlet weak var scrollView: UIScrollView!  //
    @IBOutlet weak var swapBtn: UIButton!         // ipad
    
    @IBOutlet weak var constraintNextBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var constratintNextBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForTitletoBtn: NSLayoutConstraint!
    @IBOutlet weak var constraintSpendableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    
    let presenter = SendAmountPresenter()
    
    let numberFormatter = NumberFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.sendAmountVC = self
        numberFormatter.numberStyle = .decimal
        
        presenter.setAmountFromQr()
        presenter.cryptoToUsd()
        presenter.setSpendableAmountText()
        presenter.setMaxAllowed()
        presenter.makeMaxSumWithFeeAndDonate()
        setSumInNextBtn()
        
        if (self.amountTF.text?.isEmpty)! {
            amountTF.text = "0"
        }
        presenter.getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fixForIpadAndIphoneX()
        self.nextBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                                 UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                                   gradientOrientation: .horizontal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard), name: NSNotification.Name(rawValue: "hideKeyboard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard), name: NSNotification.Name(rawValue: "showKeyboard"), object: nil)
        self.amountTF.resignFirstResponder()
        self.amountTF.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func payForCommisionAction(_ sender: Any) {
        self.presenter.checkMaxEntered()
        if self.presenter.isMaxEntered {
            self.presentWarning(message: self.presenter.messageForAlert())
            self.commissionSwitch.isOn = false
        } else {
            self.setSumInNextBtn()
        }
        self.presenter.setMaxAllowed()
    }
    
    
    
    
    @IBAction func changeAction(_ sender: Any) {
        if self.presenter.isCrypto {
            self.presenter.isCrypto = !self.presenter.isCrypto
            self.presenter.makeMaxSumWithFeeAndDonate()
            if self.presenter.sumInFiat > (self.presenter.availableSumInFiat)! {
                self.amountTF.text = "\((self.presenter.availableSumInFiat ?? 0.0).fixedFraction(digits: 2))"
                self.topSumLbl.text = "\((self.presenter.availableSumInFiat ?? 0.0).fixedFraction(digits: 2))"
            } else {
                self.amountTF.text = "\((self.presenter.sumInFiat).fixedFraction(digits: 2))"
                self.topSumLbl.text = "\((self.presenter.sumInFiat).fixedFraction(digits: 2))"
            }
            if self.presenter.sumInCrypto > (self.presenter.availableSumInCrypto)! {
                self.bottomSumLbl.text = "\((self.presenter.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8)) "
            } else {
                self.bottomSumLbl.text = "\((self.presenter.sumInCrypto).fixedFraction(digits: 8)) "
            }
            self.bottomCurrencyLbl.text = "\(self.presenter.cryptoName)"
            self.topCurrencyNameLbl.text = "\(self.presenter.fiatName)"
        } else {
            self.presenter.isCrypto = !self.presenter.isCrypto
            self.presenter.makeMaxSumWithFeeAndDonate()
            if self.presenter.sumInCrypto > (self.presenter.availableSumInCrypto)! || self.presenter.sumInCrypto > self.presenter.cryptoMaxSumWithFeeAndDonate {
                switch self.commissionSwitch.isOn {
                case true:
                    self.amountTF.text = self.presenter.cryptoMaxSumWithFeeAndDonate.fixedFraction(digits: 8)
                    self.topSumLbl.text = self.presenter.cryptoMaxSumWithFeeAndDonate.fixedFraction(digits: 8)
                case false:
                    self.amountTF.text = "\((self.presenter.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8))"
                    self.topSumLbl.text = "\((self.presenter.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8))"
                }
            } else {
                self.amountTF.text = self.presenter.sumInCrypto.fixedFraction(digits: 8)
                self.topSumLbl.text = self.presenter.sumInCrypto.fixedFraction(digits: 8)
            }
            
            if self.presenter.sumInFiat > (self.presenter.availableSumInFiat)! {
                self.bottomSumLbl.text = "\((self.presenter.availableSumInFiat ?? 0.0).fixedFraction(digits: 2)) "
            } else {
                 self.bottomSumLbl.text = "\((self.presenter.sumInFiat).fixedFraction(digits: 2)) "
            }
            self.topCurrencyNameLbl.text = self.presenter.cryptoName
            self.bottomCurrencyLbl.text = self.presenter.fiatName
        }
        
        self.amountTF.text = self.amountTF.text?.replacingOccurrences(of: ".", with: ",")
        self.bottomSumLbl.text = self.bottomSumLbl.text?.replacingOccurrences(of: ".", with: ",")
        self.topSumLbl.text = self.topSumLbl.text?.replacingOccurrences(of: ".", with: ",")
        
        self.presenter.setSpendableAmountText()
        self.presenter.setMaxAllowed()
        self.setSumInNextBtn()
    }
    
    
    @objc func hideKeyboard() {
//        self.amountTF.resignFirstResponder()
    }
    
    @objc func showKeyboard() {
        self.amountTF.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let inset : UIEdgeInsets = UIEdgeInsetsMake(64, 0, keyboardSize.height, 0)
            self.constraintNextBtnBottom.constant = inset.bottom
        }
    }
    
    @IBAction func maxAction(_ sender: Any) {
        if self.presenter.isCrypto {
            self.commissionSwitch.isOn = false
            self.presenter.setMaxAllowed()
            self.amountTF.text = "\((self.presenter.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8))"
            self.topSumLbl.text = "\((self.presenter.availableSumInCrypto ?? 0.0).fixedFraction(digits: 8))"
            self.presenter.sumInCrypto = self.presenter.availableSumInCrypto ?? 0.0
            self.presenter.cryptoToUsd()
            self.setSumInNextBtn()
        } else {
            self.commissionSwitch.isOn = false
            self.presenter.setMaxAllowed()
            self.amountTF.text = "\((self.presenter.availableSumInFiat ?? 0.0).fixedFraction(digits: 2))"
            self.topSumLbl.text = "\((self.presenter.availableSumInFiat ?? 0.0).fixedFraction(digits: 2))"
            self.presenter.sumInFiat = self.presenter.availableSumInFiat ?? 0.0
            self.presenter.usdToCrypto()
            self.setSumInNextBtn()
        }
        self.presenter.saveTfValue()
    }

    
    
    @IBAction func nextAction(_ sender: Any) {
        if self.presenter.sumInCrypto != 0.0 && self.presenter.donationObj != nil && !amountTF.text!.isEmpty && convertBTCStringToSatoshi(sum: amountTF.text!) != 0 {
            self.performSegue(withIdentifier: "sendFinishVC", sender: sender)
        } else {
            self.presentWarning(message: "You try to send 0.0 \(self.presenter.cryptoName).\nPlease enter the correct value")
        }
    }
    
    func presentWarning(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "" {
            if string.toStringWithComma() > self.presenter.maxAllowedToSpend {
                self.presentWarning(message: "You trying to enter sum more then you have")
                
                return false
            }
        }
        
        if let textString = textField.text {
            if textString == "0" && string != "," && string != "." && !string.isEmpty {
                return false
            } else if textString.isEmpty && (string == "," || string == ".") {
                return false
            }
        }
        
        if (string != "," && string != ".") && (self.topSumLbl.text! + string).toStringWithComma() > self.presenter.maxAllowedToSpend {
            if string != "" {
                self.presentWarning(message: "You trying to enter sum more then you have")
                return false
            }
        }
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength <= self.presenter.maxLengthForSum {
            self.amountTF.text = self.amountTF.text?.replacingOccurrences(of: ".", with: ",")
            if (string == "," || string == ".") && (self.amountTF.text?.contains(","))!{
                return false
            }
            
            if (self.amountTF.text?.contains(","))! && string != "" {
                let strAfterDot: [String?] = (self.amountTF.text?.components(separatedBy: ","))!
                if self.presenter.isCrypto {
                    if strAfterDot[1]?.count == 8 {
                        return false
                    } else {
                        self.topSumLbl.text = self.amountTF.text! + string                                
                        self.presenter.saveTfValue()
                    }
                } else {
                    if strAfterDot[1]?.count == 2 {
                        return false
                    } else {
                        self.topSumLbl.text = self.amountTF.text! + string
                        self.presenter.saveTfValue()
                    }
                }
            }
            
            if string == "," || string == "." {
                self.topSumLbl.text = self.amountTF.text! + ","
            } else {
                if string != "" {
                    self.topSumLbl.text = self.amountTF.text! + string
                } else {
                    self.topSumLbl.text?.removeLast()
                }
            }
            self.presenter.saveTfValue()
        }
//        self.presenter.setMaxAllowed()
        self.presenter.checkMaxEntered()
        self.setSumInNextBtn()
        
        return newLength <= self.presenter.maxLengthForSum
    }
    
    
    func setSumInNextBtn() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.perform(#selector(self.changeSum), with: nil, afterDelay: 0.3)
    }
    
    @objc func changeSum() {
        let sumForBtn = self.presenter.getNextBtnSum()
        if self.presenter.isCrypto {
            self.btnSumLbl.text = "\(sumForBtn.fixedFraction(digits: 8)) \(self.presenter.cryptoName)"
        } else {
            self.btnSumLbl.text = "\(sumForBtn.fixedFraction(digits: 2)) \(self.presenter.fiatName)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendFinishVC" {
            let sendFinishVC = segue.destination as! SendFinishViewController
            sendFinishVC.presenter.addressToStr =   presenter.addressToStr
            sendFinishVC.presenter.walletFrom =     presenter.wallet
            sendFinishVC.presenter.sumInFiat =      presenter.sumInFiat
            sendFinishVC.presenter.cryptoName =     presenter.cryptoName
            sendFinishVC.presenter.fiatName =       presenter.fiatName
            sendFinishVC.presenter.transactionObj = presenter.transactionObj
            sendFinishVC.presenter.sumInCrypto =    presenter.sumInCrypto
            sendFinishVC.presenter.isCrypto =       presenter.isCrypto
            sendFinishVC.presenter.endSum =         presenter.getNextBtnSum()
            sendFinishVC.presenter.rawTransaction = presenter.rawTransaction
            sendFinishVC.presenter.account =        presenter.account
            sendFinishVC.presenter.addressData =    presenter.addressData
        }
    }
    
    func test () {
        DataManager.shared.getAccount { (account, error) in
            
        }
    }
    
    func fixForIpadAndIphoneX() {
        if screenHeight == 480 { 
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height - 50)
            scrollView.setContentOffset(bottomOffset, animated: true)
            self.constraintSpendableViewBottom.constant = 0
            self.constraintForTitletoBtn.constant = 10
        } else if screenHeight == 812 {
            self.constraintForTitletoBtn.constant = 175
        } else if screenHeight == 736 {
            self.constraintForTitletoBtn.constant = 165
        } else if screenHeight == 568 {
            self.constraintForTitletoBtn.constant = 20
            self.constraintSpendableViewBottom.constant = 0
            self.constraintTop.constant = 20
            self.scrollView.isScrollEnabled = false
        }
    }
}
