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
        
//        walletSettingsVC?.loader.text = "Deleting Wallet"
        walletSettingsVC?.loader.show(customTitle: walletSettingsVC!.localize(string: Constants.deletingString))
        
        DataManager.shared.realmManager.getAccount { (acc, err) in
            guard acc != nil else {
                self.walletSettingsVC?.loader.hide()
                
                return
            }
            
            DataManager.shared.apiManager.deleteWallet(currencyID:  self.wallet!.chain,
                                                       networkID:   self.wallet!.chainType,
                                                       walletIndex: self.wallet!.walletID,
                                                       completion: { (answer, err) in
                self.walletSettingsVC?.loader.hide()
                self.walletSettingsVC?.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    func changeWalletName() {
//        walletSettingsVC?.progressHUD.text = "Changing name"
        walletSettingsVC?.loader.show(customTitle: walletSettingsVC!.localize(string: Constants.updatingString))
        
        DataManager.shared.getAccount { (account, error) in
            DataManager.shared.changeWalletName(currencyID:self.wallet!.chain,
                                                chainType: self.wallet!.chainType,
                                                walletID: self.wallet!.walletID,
                                                newName: self.walletSettingsVC!.walletNameTF.text!.trimmingCharacters(in: .whitespaces)) { (dict, error) in
                print(dict)
                self.walletSettingsVC?.loader.hide()
                self.walletSettingsVC!.navigationController?.popViewController(animated: true)
            }
        }
    }
}
