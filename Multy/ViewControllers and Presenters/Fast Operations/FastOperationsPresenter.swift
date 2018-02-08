//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class FastOperationsPresenter: NSObject, QrDataProtocol {

    var fastOperationsVC: FastOperationsViewController?
    
    var addressSendTo = ""
    var amountInCrypto = 0.0
    
    func qrData(string: String) {
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
        
        let storyboard = UIStoryboard(name: "Send", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "sendStart") as! SendStartViewController
        destVC.presenter.addressSendTo = self.addressSendTo
        destVC.presenter.amountInCrypto = self.amountInCrypto
        self.fastOperationsVC?.navigationController?.pushViewController(destVC, animated: true)
    }
    
}
