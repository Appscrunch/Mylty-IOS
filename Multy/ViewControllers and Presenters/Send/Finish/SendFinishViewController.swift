//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendFinishViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var cryptoSumLbl: UILabel!
    @IBOutlet weak var cryptoNamelbl: UILabel!
    @IBOutlet weak var fiatSumAndCurrancyLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var noteTF: UITextField!
    
    @IBOutlet weak var walletNameLbl: UILabel!
    @IBOutlet weak var walletCryptoSumAndCurrencyLbl: UILabel!
    @IBOutlet weak var walletFiatSumAndCurrencyLbl: UILabel!
    
    @IBOutlet weak var transactionSpeedNameLbl: UILabel!
    @IBOutlet weak var transactionSpeedTimeLbl: UILabel!
    @IBOutlet weak var transactionFeeCostLbl: UILabel! // exp: 0.002 BTC / 1.54 USD
    
    @IBOutlet weak var btnTopConstraint: NSLayoutConstraint!
    
    let presenter = SendFinishPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fixUIForX()
        self.presenter.sendFinishVC = self
        self.hideKeyboardWhenTappedAround()
        self.presenter.makeEndSum()

        self.noteTF.delegate = self

        self.setupUI()
    }
    
    func setupUI() {
        self.cryptoSumLbl.text = "\(presenter.sumInCrypto?.fixedFraction(digits: 8) ?? "0.0")"
        self.cryptoNamelbl.text = "\(self.presenter.cryptoName ?? "BTC")"
        self.fiatSumAndCurrancyLbl.text = "\(self.presenter.sumInFiat?.fixedFraction(digits: 2) ?? "0.0") \(self.presenter.fiatName ?? "USD")"
        self.addressLbl.text = self.presenter.addressToStr
        self.walletNameLbl.text = self.presenter.walletFrom?.name
        
        self.walletCryptoSumAndCurrencyLbl.text = "\(self.presenter.walletFrom?.sumInCrypto.fixedFraction(digits: 8) ?? "0.0") \(self.presenter.walletFrom?.cryptoName ?? "")"
        let fiatSum = ((self.presenter.walletFrom?.sumInCrypto)! * exchangeCourse).fixedFraction(digits: 2)
        self.walletFiatSumAndCurrencyLbl.text = "\(fiatSum) \(self.presenter.walletFrom?.fiatName ?? "")"
        self.transactionFeeCostLbl.text = "\((presenter.transactionObj?.sumInCrypto ?? 0.0).fixedFraction(digits: 8)) \(presenter.transactionObj?.cryptoName ?? "")/\((presenter.transactionObj?.sumInFiat ?? 0.0).fixedFraction(digits: 2)) \(presenter.transactionObj?.fiatName ?? "")"
        self.transactionSpeedNameLbl.text = "\(self.presenter.transactionObj?.speedName ?? "") "
        self.transactionSpeedTimeLbl.text =  "\(self.presenter.transactionObj?.speedTimeString ?? "")"
        if self.view.frame.height == 736 {
            self.btnTopConstraint.constant = 105
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let newAddressParams = [
            "walletindex"   : presenter.walletFrom!.walletID.intValue,
            "address"       : presenter.addressData!["address"] as! String,
            "addressindex"  : presenter.walletFrom!.addresses.count,
            "transaction"   : self.presenter.rawTransaction!,
            "ishd"          : NSNumber(booleanLiteral: true)
            ] as [String : Any]
        
        let params = [
            "currencyid": presenter.walletFrom!.chain,
            "payload"   : newAddressParams
            ] as [String : Any]
        
        DataManager.shared.sendHDTransaction(transactionParameters: params) { (dict, error) in
            print("---------\(dict)")
            
            if error != nil {
                self.presentAlert()
                
                print("sendHDTransaction Error: \(error)")
                
                return
            }
            
            if dict!["code"] as! Int == 200 {
                self.performSegue(withIdentifier: "sendingAnimationVC", sender: sender)
            } else {
                self.presentAlert()
            }
        }
        
//        DataManager.shared.addAddress(presenter.account!.token, params: newAddressParams) { (dict, error) in
//            if error != nil {
//
//
//                return
//            }
//
//            let params = [
//                "transaction" : self.presenter.rawTransaction!
//                ] as [String : Any]
//
//            DataManager.shared.apiManager.sendRawTransaction(self.presenter.account!.token,
//                                                             walletID: self.presenter.walletFrom!.walletID,
//                                                             transactionParameters: params,
//                                                             completion: { (dict, error) in
//                                                                print("---------\(dict)")
//                                                                self.performSegue(withIdentifier: "sendingAnimationVC", sender: sender)
//            })
//        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func presentAlert() {
        let message = "Error while sending transaction. Please, try again!"
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func fixUIForX() {
        if screenHeight == 812 {
            self.btnTopConstraint.constant = 110
        }
    }
}
