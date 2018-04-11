//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class CustomFeeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var topNameLbl: UILabel!  //gas price
    @IBOutlet weak var topPriceTF: UITextField!
    
    @IBOutlet weak var botNameLbl: UILabel!   //gas limit
    @IBOutlet weak var botLimitTf: UITextField!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint! // for btc   /2 and hide bot elems
    
    let presenter = CustomFeePresenter()
    
    weak var delegate: CustomFeeRateProtocol?
    
    var rate = 0
    var previousSelected: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeToBack()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topPriceTF.becomeFirstResponder()
    }

    func setupUI() {
        //FIXME: check chainID nullability
        switch self.presenter.chainId {
        case 0 as NSNumber:
            self.botNameLbl.isHidden = true
            self.botLimitTf.isHidden = true
            self.viewHeightConstraint.constant = viewHeightConstraint.constant / 2
            
            self.topPriceTF.addDoneCancelToolbar(onDone: (target: self, action: #selector(done)))
            self.topNameLbl.text = "Satoshi per byte"
            self.topPriceTF.placeholder = "Enter Satohi per byte here"
            self.topPriceTF.placeholder = "0"
            if self.rate != 0 {
                self.topPriceTF.text = "\(rate)"
            }
        default: return
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        //for BTC
        self.delegate?.setPreviousSelected(index: self.previousSelected)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func done() {
        if topPriceTF.text == nil || (topPriceTF.text! as NSString).intValue < 2 {
            let message = "Fee rate can not be less then 2 satoshi per byte."
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.topPriceTF.becomeFirstResponder()
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.delegate?.customFeeData(firstValue: (self.topPriceTF.text! as NSString).integerValue, secValue: (self.botLimitTf.text! as NSString).integerValue)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "," && (textField.text?.contains(","))! {
            return false
        }
        
        let endString = textField.text! + string
        if UInt64(endString)! > 3000 {
            let message = "You fee is too high. Please enter normal fee amount!"
            let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.topPriceTF.becomeFirstResponder()
            }))
            
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
}
