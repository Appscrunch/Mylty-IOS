//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class ReceiveAllDetailsPresenter: NSObject, ReceiveSumTransferProtocol, SendWalletProtocol {

    var receiveAllDetailsVC: ReceiveAllDetailsViewController?
    
    var cryptoSum: String?
    var cryptoName: String?
    var fiatSum: String?
    var fiatName: String?
    
    var walletAddress = ""
    
    var wallet: UserWalletRLM? {
        didSet {
            if wallet != nil {
                qrBlockchainString = BlockchainType.create(wallet: wallet!).qrBlockchainString
            }
        }
    }
    
    var qrBlockchainString = String()
    

    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangedBluetoothReachability(notification:)), name: Notification.Name(bluetoothReachabilityChangedNotificationName), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(bluetoothReachabilityChangedNotificationName), object: nil)
    }
    
    func viewControllerViewDidLoad() {
        handleBluetoothReachability()
    }
    
    func transferSum(cryptoAmount: String, cryptoCurrency: String, fiatAmount: String, fiatName: String) {
        self.cryptoSum = cryptoAmount
        self.cryptoName = cryptoCurrency
        self.fiatSum = fiatAmount
        self.fiatName = fiatName
        
        self.receiveAllDetailsVC?.setupUIWithAmounts()
        
        if self.receiveAllDetailsVC!.option == .wireless {
            tryReceiveViaWireless()
        }
    }
    
    func sendWallet(wallet: UserWalletRLM) {
        self.receiveAllDetailsVC?.updateUIWithWallet()
        
        if self.receiveAllDetailsVC!.option == .wireless {
            tryReceiveViaWireless()
        }
    }
    
    func didChangeReceivingOption() {
        switch self.receiveAllDetailsVC!.option {
        case .qrCode:
            stopReceivingViaWireless()
            stopSharingUserCode()
            break
            
        case .wireless:
            tryReceiveViaWireless()
            break
        }
    }
    
    private func handleBluetoothReachability() {
        if self.receiveAllDetailsVC?.option == .wireless {
            tryReceiveViaWireless()
        }
    }
    
    private func tryReceiveViaWireless() {
        if self.receiveAllDetailsVC!.option == .wireless {
            let reachability = BLEManager.shared.reachability
            if reachability == .notReachable {
                self.receiveAllDetailsVC?.presentBluetoothErrorAlert()
            } else if reachability == .reachable {
                if !BLEManager.shared.isAdvertising {
                    DataManager.shared.getAccount { (account, error) in
                        if account != nil {
                            let userID = account!.userID
                            let userCode = self.userCodeForUserID(userID: userID)
                            self.becomeReceiver(userID: userID, userCode: userCode)
                            self.shareUserCode(code: userCode)
                        }
                    }
                }
            }
        }
    }
    
    private func stopReceivingViaWireless() {
        if BLEManager.shared.isAdvertising {
            stopSharingUserCode()
        }
    }
    
    private func shareUserCode(code : String) {
        if !BLEManager.shared.isAdvertising {
            //TODO: make a decision about userID
            BLEManager.shared.advertise(userId: code)
        }
    }
    
    func userCodeForUserID(userID : String) -> String {
        var result = String()
        result = String(userID[..<userID.index(userID.startIndex, offsetBy: 8)])
        return result
    }
    
    private func stopSharingUserCode() {
        if BLEManager.shared.isAdvertising {
            BLEManager.shared.stopAdvertising()
        }
    }
    
    private func becomeReceiver(userID : String, userCode : String) {
        guard self.wallet != nil else {
            return
        }
        
        let blockchainType = BlockchainType.create(wallet: self.wallet!)
        let currencyID = self.wallet!.chain
        let networkID = blockchainType.net_type
        let address = self.wallet!.address
        let amount = cryptoSum != nil ? String(cryptoSum!) : "0"
        
        DataManager.shared.socketManager.becomeReceiver(receiverID: userID, userCode: userCode, currencyID: currencyID.intValue, networkID: networkID, address: address, amount: amount)
        //self.receiveAllDetailsVC?.presentDidReceivePaymentAlert(amount: 0)
    }
    
    @objc private func didChangedBluetoothReachability(notification: Notification) {
        DispatchQueue.main.async {
            self.handleBluetoothReachability()
        }
    }
}
