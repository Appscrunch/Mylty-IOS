//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class WalletSettingsPresenter: NSObject {

    var walletSettingsVC: WalletSettingsViewController?
    
    var wallet: UserWalletRLM?
    
    func delete() {
        if wallet == nil {
            print("\nWrong wallet data: wallet == nil\n")
            
            return
        }
        
        walletSettingsVC?.progressHUD.text = "Deleting Wallet"
        walletSettingsVC?.progressHUD.show()
        
        DataManager.shared.realmManager.getAccount { (acc, err) in
            guard acc != nil else {
                self.walletSettingsVC?.progressHUD.hide()
                
                return
            }
            
            DataManager.shared.apiManager.deleteWallet(currencyID: self.wallet!.chain, walletIndex: self.wallet!.walletID, completion: { (answer, err) in
                self.walletSettingsVC?.progressHUD.hide()
                self.walletSettingsVC?.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    func changeWalletName() {
        walletSettingsVC?.progressHUD.text = "Changing name"
        walletSettingsVC?.progressHUD.show()
        
        DataManager.shared.getAccount { (account, error) in
            DataManager.shared.changeWalletName(currencyID:self.wallet!.chain , walletID: self.wallet!.walletID, newName: self.walletSettingsVC!.walletNameTF.text!.trimmingCharacters(in: .whitespaces)) { (dict, error) in
                print(dict)
                self.walletSettingsVC?.progressHUD.hide()
                self.walletSettingsVC!.navigationController?.popViewController(animated: true)
            }
        }
    }
}
