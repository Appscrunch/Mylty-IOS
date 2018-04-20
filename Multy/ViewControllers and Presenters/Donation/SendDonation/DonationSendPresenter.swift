//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

class DonationSendPresenter: NSObject, CustomFeeRateProtocol, SendWalletProtocol {

    var mainVC: DonationSendViewController?
    
    var selectedIndexOfSpeed: Int?
    
    var customFee = UInt64(20)
    
    var walletPayFrom: UserWalletRLM?
    
    var maxAvailable = 0.0
    
    var donationAddress = ""
    var btcWallets = [UserWalletRLM]()
    
    var feeRate: NSDictionary? {
        didSet {
            mainVC?.tableView.reloadData()
        }
    }
    
    func customFeeData(firstValue: Int?, secValue: Int?) {
        if selectedIndexOfSpeed != 5 {
            selectedIndexOfSpeed = 2
        }
        let cell = self.mainVC?.tableView.cellForRow(at: [0, selectedIndexOfSpeed!]) as! CustomTrasanctionFeeTableViewCell
        cell.value = (firstValue)!
        cell.setupUIFor(gasPrice: nil, gasLimit: nil)
        self.mainVC?.isTransactionSelected = true
        self.customFee = UInt64(firstValue!)
        self.mainVC?.tableView.reloadData()
        self.mainVC?.makeSendAvailable(isAvailable: true)
    }
    
    func setPreviousSelected(index: Int?) {
        
    }
    
    func getAddress() {
        let addresses = DataManager.shared.getBTCDonationAddressesFromUserDerfaults()
        donationAddress = addresses[DataManager.shared.donationCode]!
    }
    
    func getWallets() {
        self.mainVC?.view.isUserInteractionEnabled = false
        DataManager.shared.realmManager.fetchBTCWallets(isTestNet: false) { (wallets) in
            if wallets != nil {
                self.btcWallets = wallets!
            }
            self.mainVC?.view.isUserInteractionEnabled = true
            self.walletPayFrom = wallets?.first
            self.maxAvailable = (self.walletPayFrom?.sumInCrypto)!
            self.mainVC?.updateUIWithWallet()
        }
    }
    
    func sendWallet(wallet: UserWalletRLM) {
        self.walletPayFrom = wallet
        self.mainVC?.updateUIWithWallet()
    }
    
    func makeFiatDonat() {
        let exchangeCourse = walletPayFrom!.exchangeCourse
        let cryptoDonat = self.mainVC?.donationTF.text //string
        let cryptoDonatWithDot = cryptoDonat?.replacingOccurrences(of: ",", with: ".") as NSString?
        let fiatDonat = (cryptoDonatWithDot!.doubleValue) * exchangeCourse
        
        self.mainVC?.fiatDonationLbl.text = "\(fiatDonat.fixedFraction(digits: 2)) USD"
    }
    
    func createAndSendTransaction() {
        let transaction = TransactionDTO()
        transaction.choosenWallet = self.walletPayFrom
        transaction.sendAddress = donationAddress
        transaction.sendAmount = self.mainVC?.donationTF.text?.convertStringWithCommaToDouble()
        transaction.transaction?.customFee = self.customFee
        
        DataManager.shared.createAndSendDonationTransaction(transactionDTO: transaction) { [unowned self] (answer, err) in
            self.mainVC?.progressHud.unblockUIandHideProgressHUD()
            
            if err != nil {
                if answer != nil {
                    self.mainVC?.presentAlert(with: answer)
                }
                
                return
            }
            
            self.mainVC?.view.isUserInteractionEnabled = true
            if err != nil {
                let alert = UIAlertController(title: "Error", message: err.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.mainVC?.present(alert, animated: true, completion: nil)
                return
            } else {
                self.mainVC!.sendDonationSuccessAnalytics()
            }
            
            if transaction.sendAmount! < minSatoshiToDonate.btcValue {
                self.mainVC!.presentWarning(message: "Too low donation amount")
                return
            }
            
            let storyboard = UIStoryboard(name: "Send", bundle: nil)
            let sendSuccessVC = storyboard.instantiateViewController(withIdentifier: "SuccessSendVC") as! SendingAnimationViewController
            sendSuccessVC.indexForTabBar = self.mainVC?.selectedTabIndex
            sendSuccessVC.chainId = transaction.choosenWallet?.chain as? Int
            self.mainVC?.navigationController?.pushViewController(sendSuccessVC, animated: true)
        }
    }
}
