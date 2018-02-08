//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendStartPresenter: NSObject, CancelProtocol, SendAddressProtocol, GoToQrProtocol, QrDataProtocol {
    
    var sendStartVC: SendStartViewController?
    
    var addressSendTo = ""
    
    var amountInCrypto = 0.0
    
    var choosenWallet: UserWalletRLM?
    
    var isFromWallet = false
    
    func cancelAction() {
        if self.isFromWallet {
            self.sendStartVC?.navigationController?.popViewController(animated: true)
        } else {
            if let tbc = self.sendStartVC?.tabBarController as? CustomTabBarViewController {
                tbc.setSelectIndex(from: 2, to: tbc.previousSelectedIndex)
            }
            self.sendStartVC?.navigationController?.popToRootViewController(animated: false)
        }
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
        self.addressSendTo = address
        self.sendStartVC?.modifyNextButtonMode()
    }
    
    func goToScanQr() {
        self.sendStartVC?.performSegue(withIdentifier: "qrCamera", sender: Any.self)
    }
  
    func qrData(string: String) {
//        if sting.contains(":") {
//            let separatedString = sting.components(separatedBy: ":")
//            let blockchainName = separatedString[0]
//            print(blockchainName)  // bitcoin
//            if separatedString[1].contains("?") {
//                let separatedAddress = separatedString[1].components(separatedBy: "?")[0]
//                print(separatedAddress)  // wallet address
//                let separatedAmount = separatedString[1].components(separatedBy: "?")[1]
//                if separatedAmount.contains("amount") {
//                    let sumInCrypto = separatedAmount.components(separatedBy: "=")[1]
//                    print(sumInCrypto) // amount sum
//                }
//            } else {
//                let separatedAddress = separatedString[1]
//                print(separatedAddress) // wallet address
//            }
//        }
        let array = string.components(separatedBy: CharacterSet(charactersIn: ":?="))
        switch array.count {
        case 1:                              // shit in qr
            let messageFromQr = array[0]
            self.addressSendTo = messageFromQr
            print(messageFromQr)
        case 2:                              // chain name + address
//            let blockchainName = array[0]
            let addressStr = array[1]
//            print(blockchainName, addressStr)
            self.addressSendTo = addressStr
        case 4:                                // chain name + address + amount
//            let blockchainName = array[0]
            let addressStr = array[1]
            let amount = array[3]
//            print(blockchainName, addressStr, amount)
            self.addressSendTo = addressStr
            self.amountInCrypto = (amount as NSString).doubleValue
        default:
            return
        }
        self.sendStartVC?.modifyNextButtonMode()
        self.sendStartVC?.updateUI()
    }
}
