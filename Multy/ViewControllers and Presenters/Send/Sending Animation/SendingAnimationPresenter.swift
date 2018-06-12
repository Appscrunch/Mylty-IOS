//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class SendingAnimationPresenter: NSObject, ReceiveSumTransferProtocol {
    var sendingAnimationVC : SendingAnimationViewController?
    
    var transactionAddress : String?
    var transactionAmount : String?
    
    func viewControllerViewWillAppear() {
        sendingAnimationVC?.updateUI()
    }
    
    func fundsReceived(_ amount: String,_ address: String) {
        transactionAddress = address
        transactionAmount = amount
    }
}
