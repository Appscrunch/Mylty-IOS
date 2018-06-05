//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import ZFRippleButton

private typealias LocalizeDelegate = ReceiveAmountViewController

class ReceiveAmountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var doneBtn: ZFRippleButton!
    @IBOutlet weak var sumLbl: UILabel!
    @IBOutlet weak var currencyNameLbl: UILabel!
    @IBOutlet weak var bottomSumLbl: UILabel!
    @IBOutlet weak var bottomCurrencyNameLbl: UILabel!
    @IBOutlet weak var constraintBtnBottom: NSLayoutConstraint!
    
    @IBOutlet weak var btnTopConstraint: NSLayoutConstraint! // ipad
    
    let presenter = ReceiveAmountPresenter()
    
//    var sumInCrypto = 0.0
    var sumInCryptoString = "0.0"
//    var sumInFiat = 0.0
    var sumInFiatString = "0.0"
    
    var blockchainType = BlockchainType.create(currencyID: 0, netType: 0)
    
    var isCrypto = true
    
    var fiatName = "USD"
    var cryptoName = "BTC"
    
    var maxLengthForSum = 20
    
    weak var delegate: ReceiveSumTransferProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeToBack()
        presenter.receiveAmountVC = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        cryptoName = blockchainType.shortName
        tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        fixForIpad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if sumInCryptoString.doubleValue != 0.0 {
            amountTF.text = sumInCryptoString
        }
        sumLbl.text = sumInCryptoString
        currencyNameLbl.text = cryptoName
        bottomSumLbl.text = sumInCryptoString.fiatValueString(for: blockchainType)
        bottomCurrencyNameLbl.text = fiatName
        
        amountTF.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        doneBtn.applyGradient(withColours: [UIColor(ciColor: CIColor(red: 0/255, green: 178/255, blue: 255/255)),
                                            UIColor(ciColor: CIColor(red: 0/255, green: 122/255, blue: 255/255))],
                              gradientOrientation: .horizontal)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeAction(_ sender: Any) {
        if isCrypto {
            if sumInFiatString.doubleValue != 0.0 {
                amountTF.text = sumInFiatString
            } else {
                amountTF.text = ""
            }
            bottomSumLbl.text = sumInCryptoString + " "
            bottomCurrencyNameLbl.text = currencyNameLbl.text?.uppercased()
            sumLbl.text = sumInFiatString
            currencyNameLbl.text = fiatName
        } else {
            if sumInCryptoString.doubleValue != 0.0 {
                amountTF.text = sumInCryptoString + " "
            } else {
                amountTF.text = ""
            }
            sumLbl.text = sumInCryptoString + " "
            currencyNameLbl.text = cryptoName
            bottomSumLbl.text = sumInFiatString + " "
            bottomCurrencyNameLbl.text = fiatName
        }
        
        amountTF.text = amountTF.text?.replacingOccurrences(of: ".", with: ",")
        bottomSumLbl.text = bottomSumLbl.text?.replacingOccurrences(of: ".", with: ",")
        sumLbl.text = sumLbl.text?.replacingOccurrences(of: ".", with: ",")
        if amountTF.text!.contains(" ") {
            amountTF.text = amountTF.text?.replacingOccurrences(of: " ", with: "")  //delete space after exchange action
        }
        
        isCrypto = !isCrypto
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if sumInCryptoString.convertCryptoAmountStringToMinimalUnits(in: blockchainType.blockchain) == Int64(0) {
            presentAlert(with: "Please, enter non-zero amount!")
            
            return
        }
        
        delegate?.transferSum(cryptoAmount: sumInCryptoString, cryptoCurrency: cryptoName, fiatAmount: sumInFiatString, fiatName: fiatName)
        navigationController?.popViewController(animated: true)
    }
   
    @objc func keyboardWillShow(_ notification : Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let inset : UIEdgeInsets = UIEdgeInsetsMake(64, 0, keyboardSize.height, 0)
            constraintBtnBottom.constant = inset.bottom
        }
    }
    
    func presentWarning(message: String) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch isCrypto{
        case true:
            if ((amountTF.text! + string) as NSString).doubleValue > presenter.getMaxValueOfChain(curency: blockchainType.blockchain) {
                presentWarning(message: "You can`t enter sum more than chain have")
                
                return false
            }
        case false:
            let exchangeCourse = DataManager.shared.makeExchangeFor(blockchainType: blockchainType)
            if ((amountTF.text! + string) as NSString).doubleValue/exchangeCourse > presenter.getMaxValueOfChain(curency: blockchainType.blockchain) {
                presentWarning(message: "You can`t enter sum more than chain have")
                
                return false
            }
        }
        
        if let textString = textField.text {
            if textString == "0" && string != "," && string != "." && !string.isEmpty {
                return false
            } else if textString.isEmpty && (string == "," || string == ".") {
                self.amountTF.text = "0" + string
                self.sumLbl.text = self.amountTF.text
                return false
            }
        }
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if newLength <= self.maxLengthForSum {
            self.amountTF.text = self.amountTF.text?.replacingOccurrences(of: ".", with: ",")
            
            if (string == "," || string == ".") && (self.amountTF.text?.contains(","))!{
                return false
            }
            
            if (self.amountTF.text?.contains(","))! && string != "" {
                let strAfterDot: [String?] = (self.amountTF.text?.components(separatedBy: ","))!
                if self.isCrypto {
                    if strAfterDot[1]?.count == 8 {
                        return false
                    } else {
                        self.sumLbl.text = self.amountTF.text! + string
                        self.saveTfValue()
                    }
                } else {
                    if strAfterDot[1]?.count == 2 {
                        return false
                    } else {
                        self.sumLbl.text = self.amountTF.text! + string
                        self.saveTfValue()
                    }
                }
            }

            if string == "," || string == "." {
                self.sumLbl.text = self.amountTF.text! + ","
            } else {
                if string != "" {
                    self.sumLbl.text = self.amountTF.text! + string
                } else {
                    self.sumLbl.text?.removeLast()
                }
            }
            self.saveTfValue()
        }
        
        return newLength <= self.maxLengthForSum
    }
    
    func saveTfValue() {
        let exchangeCourse = DataManager.shared.makeExchangeFor(blockchainType: blockchainType)
        if isCrypto {
            sumInCryptoString = sumLbl.text!
            sumInFiatString = sumInCryptoString.fiatValueString(for: blockchainType)
            bottomSumLbl.text = sumInFiatString + " "
            bottomCurrencyNameLbl.text = fiatName
        } else {
            sumInFiatString = sumLbl.text!
            let sumInFiat = sumInFiatString.convertStringWithCommaToDouble()
            let sumInCrypto = sumInFiat / exchangeCourse
            sumInCryptoString = sumInCrypto.fixedFraction(digits: 8)
            bottomSumLbl.text = sumInCryptoString + " "
            bottomCurrencyNameLbl.text = cryptoName
        }
    }
    
    func fixForIpad() {
        if screenHeight == heightOfiPad {
            self.btnTopConstraint.constant = 10
        }
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Receives"
    }
}

 
