//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = SendStartPresenter

class SendStartPresenter: NSObject, CancelProtocol, SendAddressProtocol, GoToQrProtocol, QrDataProtocol {
    
    var sendStartVC: SendStartViewController?
    var transactionDTO = TransactionDTO()
    var isFromWallet = false
    
    var recentAddresses = [RecentAddressesRLM]() 
    
    func cancelAction() {
//        if self.isFromWallet {
            self.sendStartVC?.navigationController?.popViewController(animated: true)
//        } else {
//            if let tbc = self.sendStartVC?.tabBarController as? CustomTabBarViewController {
//                tbc.setSelectIndex(from: 2, to: tbc.previousSelectedIndex)
//            }
//            self.sendStartVC?.navigationController?.popToRootViewController(animated: false)
//        }
    }
    
    func presentNoInternet() {
        if !(ConnectionCheck.isConnectedToNetwork()) {
            if self.isKind(of: NoInternetConnectionViewController.self) || self.isKind(of: UIAlertController.self) {
                return
            }
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NoConnectionVC") as! NoInternetConnectionViewController
            self.sendStartVC!.present(nextViewController, animated: true, completion: nil)
        }
    }
    
    func sendAddress(address: String) {
        self.transactionDTO.sendAddress = address
        self.sendStartVC?.modifyNextButtonMode()
    }
    
    func goToScanQr() {
        self.sendStartVC?.performSegue(withIdentifier: "qrCamera", sender: Any.self)
    }
  
    func qrData(string: String) {
        transactionDTO.update(from: string)
        sendStartVC?.setTextToTV(address: transactionDTO.sendAddress!)
        self.sendStartVC?.modifyNextButtonMode()
    }
    
    func isValidCryptoAddress() -> Bool {
        if transactionDTO.sendAddress != nil && transactionDTO.choosenWallet != nil {
            let isValidDTO = DataManager.shared.isAddressValid(address: transactionDTO.sendAddress!, for: transactionDTO.choosenWallet!)
            
            if !isValidDTO.isValid {
//                presentAlert(message: isValidDTO.1!)
            }
            
            return isValidDTO.isValid
        } else {
            return transactionDTO.choosenWallet == nil
        }
    }
    
    func presentAlert(message: String) {
        let alert = UIAlertController(title: localize(string: Constants.warningString), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        sendStartVC?.present(alert, animated: true, completion: nil)
    }
    
    func isTappedDisabledNextButton(gesture: UITapGestureRecognizer) -> Bool {
        return sendStartVC!.nextBtn.frame.minY < gesture.location(in: gesture.view!).y
    }
    
    func destinationSegueString() -> String {
        switch transactionDTO.blockchainType!.blockchain {
        case BLOCKCHAIN_BITCOIN:
            return "sendBTCDetailsVC"
        case BLOCKCHAIN_ETHEREUM:
            return "sendETHDetailsVC"
        default:
            return ""
        }
    }
    
    func getAddresses() {
        if transactionDTO.choosenWallet == nil {
            RealmManager.shared.getRecentAddresses(for: nil, netType: nil) { (addresses, err) in
                if addresses?.count != 0 {
                    let arr = Array(addresses!)
                    self.recentAddresses = arr
                }
                self.sendStartVC?.updateUI()
            }
        } else {
            RealmManager.shared.getRecentAddresses(for: (transactionDTO.choosenWallet?.blockchainType.blockchain.rawValue)!,
                                                   netType: (transactionDTO.choosenWallet?.blockchainType.net_type)!) { (addresses, err) in
                if addresses?.count != 0 {
                    let arr = Array(addresses!)
                    self.recentAddresses = arr
                }
                self.sendStartVC?.updateUI()
            }
        }
    }
    
    func numberOfaddresses() -> Int {
        return self.recentAddresses.count
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Sends"
    }
}
