//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class WalletChoosePresenter: NSObject {

    var walletChoooseVC: WalletChooseViewController?
    var transactionDTO = TransactionDTO()
    
    var walletsArr = List<UserWalletRLM>()
    var filteredWalletArray = [UserWalletRLM]()
    var selectedIndex: Int? {
        didSet {
            if selectedIndex != nil {
                transactionDTO.choosenWallet = filteredWalletArray[selectedIndex!]
            }
        }
    }
    
    func numberOfWallets() -> Int {
        return filteredWalletArray.count
    }
    
    func getWallets() {
        DataManager.shared.getAccount { (acc, err) in
            if err == nil {
                // MARK: check this
                self.walletsArr = acc!.wallets
                self.filterWallets()
                self.walletChoooseVC?.updateUI()
            }
        }
    }
    
    func filterWallets() {
        if transactionDTO.sendAddress != nil {
            filteredWalletArray = walletsArr.filter{ DataManager.shared.isAddressValid(address: transactionDTO.sendAddress!, for: $0).isValid }
        } else {
            filteredWalletArray = walletsArr.filter{ _ in true }
        }
        
        walletChoooseVC?.emptyDataSourceLabel.isHidden = (filteredWalletArray.count != 0)
    }
    
    func presentAlert(message : String?) {
        var alertMessage = String()
        if message == nil {
            alertMessage = walletChoooseVC!.localize(string: Constants.notEnoughAmountString) +  " \(transactionDTO.sendAmountString ?? "0,0") \(transactionDTO.blockchain!.fullName)"
        } else {
            alertMessage = message!
        }
        
        let alert = UIAlertController(title: walletChoooseVC!.localize(string: Constants.errorString), message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        
        walletChoooseVC?.present(alert, animated: true, completion: nil)
    }
    
    func destinationSegueString() -> String {
        switch transactionDTO.blockchain {
        case BLOCKCHAIN_BITCOIN:
            return "sendBTCDetailsVC"
        case BLOCKCHAIN_ETHEREUM:
            return "sendETHDetailsVC"
        default:
            return ""
        }
    }
}
