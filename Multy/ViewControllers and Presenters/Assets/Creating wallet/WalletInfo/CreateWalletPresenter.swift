//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Firebase

class CreateWalletPresenter: NSObject {
    weak var mainVC: CreateWalletViewController?
    var account : AccountRLM?
//
    func makeAuth(completion: @escaping (_ answer: String) -> ()) {
        if self.account != nil {
            return
        }
        DataManager.shared.auth(rootKey: nil) { (account, error) in
//            self.assetsVC?.view.isUserInteractionEnabled = true
//            self.assetsVC?.progressHUD.hide()
            guard account != nil else {
                return
            }
            self.account = account
            DataManager.shared.socketManager.start()
            completion("ok")
        }
    }
    
    func createNewWallet(completion: @escaping (_ dict: Dictionary<String, Any>?) -> ()) {
        if account == nil {
//            print("-------------ERROR: Account nil")
//            return
            self.makeAuth(completion: { (answer) in
                self.create()
            })
        } else {
            self.create()
        }
    }
    
    func create() {
        var binData : BinaryData = account!.binaryDataString.createBinaryData()!
        //MARK: topIndex
        let dict = DataManager.shared.createNewWallet(for: &binData, CURRENCY_BITCOIN.rawValue, walletID: account!.topIndexes[0].topIndex.uint32Value)
        let cell = mainVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateWalletNameTableViewCell
        let params = [
            "currencyID"  : dict!["currency"] as! UInt32,
            "address"   : dict!["address"] as! String,
            "addressIndex" : dict!["addressID"] as! UInt32,
            "walletIndex" : dict!["walletID"] as! UInt32,
            "walletName"      : cell.walletNameTF.text ?? "Wallet"
            ] as [String : Any]
        
        DataManager.shared.addWallet(params: params) { (dict, error) in
            if error == nil {
                print(dict as Any)
                self.mainVC?.cancleAction(UIButton())
            } else {
                self.mainVC?.progressHUD.hide()
                self.presentAlert()
            }
        }
    }
    
    func presentAlert() {
        let message = "Error while creating wallet!"
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        mainVC?.present(alert, animated: true, completion: nil)
    }
}
