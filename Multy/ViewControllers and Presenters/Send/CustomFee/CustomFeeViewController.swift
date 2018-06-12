//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = CustomFeeViewController

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
        unowned let weakSelf =  self
        self.topPriceTF.addDoneCancelToolbar(onDone: (target: self, action: #selector(done)), viewController: weakSelf)
        
        //FIXME: check chainID nullability
        switch self.presenter.blockchainType?.blockchain {
        case BLOCKCHAIN_BITCOIN:
            self.botNameLbl.isHidden = true
            self.botLimitTf.isHidden = true
            self.viewHeightConstraint.constant = viewHeightConstraint.constant / 2
            
            
            self.topNameLbl.text = localize(string: Constants.satoshiPerByteString)
            self.topPriceTF.placeholder = localize(string: Constants.enterSatoshiPerByte)
            self.topPriceTF.placeholder = "0"
            if self.rate != 0 {
                self.topPriceTF.text = "\(rate)"
            }
        case BLOCKCHAIN_ETHEREUM:
            self.botNameLbl.isHidden = true
            self.botLimitTf.isHidden = true
            if self.rate != 0 {
                self.topPriceTF.text = "\(rate / 1000000000)"
            }
            self.viewHeightConstraint.constant = viewHeightConstraint.constant / 2
        default: return
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        if presenter.blockchainType!.blockchain == BLOCKCHAIN_ETHEREUM {
            if self.previousSelected != 5 {
                self.delegate?.setPreviousSelected(index: self.previousSelected)
            }
        } else {
            if self.previousSelected != 5 {
                self.delegate?.setPreviousSelected(index: self.previousSelected)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func minimalUnit() -> Int {
        switch presenter.blockchainType?.blockchain {
        case BLOCKCHAIN_BITCOIN:
            return Constants.CustomFee.defaultBTCCustomFeeKey
        case BLOCKCHAIN_ETHEREUM:
            return Constants.CustomFee.defaultETHCustomFeeKey
        default:
            return 1
        }
    }
    
    @objc func done() {
        let defaultCustomFee = minimalUnit()
        
        if topPriceTF.text == nil || (topPriceTF.text! as NSString).intValue < defaultCustomFee {
            switch presenter.blockchainType!.blockchain {
            case BLOCKCHAIN_BITCOIN:
                let message = "\(localize(string: Constants.feeRateLessThenString)) \(defaultCustomFee) \(localize(string: Constants.satoshiPerByteString))"
                let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self.topPriceTF.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            case BLOCKCHAIN_ETHEREUM:
                let message = localize(string: Constants.gasPriceLess1String)
                let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self.topPriceTF.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            default: return
            }
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
            let message = localize(string: Constants.feeRateLessThenString)
            let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.topPriceTF.becomeFirstResponder()
            }))
            
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
