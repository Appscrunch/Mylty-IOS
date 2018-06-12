//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class AssetsPresenter: NSObject {

    var assetsVC: AssetsViewController?
    
    var tabBarFrame: CGRect?
    
    var isJailed = false
    var tappedIndexPath = IndexPath(row: 0, section: 0)
    
    var contentOffset = CGPoint.zero
    
    var account : AccountRLM? {
        didSet {
            backupActivity()
            self.assetsVC?.tableView.alwaysBounceVertical = true
            if self.assetsVC!.isVisible() {
                if self.assetsVC!.isOnWindow() {
                    (self.assetsVC!.tabBarController as! CustomTabBarViewController).changeViewVisibility(isHidden: account == nil)
                }
            }
            
            wallets = account?.wallets.sorted(byKeyPath: "lastActivityTimestamp", ascending: false)
            
            self.assetsVC?.view.isUserInteractionEnabled = true
            if !assetsVC!.isSocketInitiateUpdating && self.assetsVC!.tabBarController!.viewControllers![0].childViewControllers.count == 1 {
                assetsVC?.tableView.reloadData()
            }
            
            if account != nil {
                assetsVC!.tableView.frame.size.height = screenHeight - assetsVC!.tabBarController!.tabBar.frame.height
            } else {
                assetsVC!.tableView.frame.size.height = screenHeight
            }
        }
    }
    
    var wallets: Results<UserWalletRLM>?
    
    func backupActivity() {
        if account != nil {
            self.assetsVC?.backupView?.isHidden = account!.isSeedPhraseSaved()
            self.assetsVC?.backupView?.isUserInteractionEnabled = !account!.isSeedPhraseSaved()
        }
    }
    
    func auth() {
        //MARK: need refactoring
        self.blockUI()
        DataManager.shared.getAccount { (acc, err) in
            self.unlockUI()
            if acc == nil {
//                self.assetsVC?.progressHUD.show()
                DataManager.shared.auth(rootKey: nil) { (account, error) in
                    self.unlockUI()
                    guard account != nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.account = account
                        
                        self.getWalletsVerbose(completion: {_ in })
                    }
                }
            } else {
                self.account = acc
                DataManager.shared.auth(rootKey: self.account?.backupSeedPhrase, completion: { (acc, err) in
                    if acc != nil {
                        self.account = acc
                        self.getWalletsVerbose(completion: {_ in})
//                        DataManager.shared.socketManager.start()
                    }
                })
            }
            DataManager.shared.socketManager.start()
//            self.assetsVC?.progressHUD.hide()
        }
    }
    
    func guestAuth(completion: @escaping (_ answer: String) -> ()) {
        self.assetsVC?.view.isUserInteractionEnabled = false
        DataManager.shared.auth(rootKey: nil) { (account, error) in
            self.assetsVC?.view.isUserInteractionEnabled = true
//            self.assetsVC?.progressHUD.hide()
            guard account != nil else {
                return
            }
            
            self.account = account
            
            DataManager.shared.socketManager.start()
            
            completion("ok")
        }
    }
    
    func updateWalletsInfo(isInternetAvailable: Bool) {
        DataManager.shared.getAccount { (acc, err) in
            if acc != nil {
//                self.blockUI()
                self.account = acc
                if isInternetAvailable == false {
//                    self.unlockUI()
                }
                self.getWalletsVerbose(completion: { (_) in
                    self.unlockUI()
                })
            }
        }
    }
    
    func isWalletExist() -> Bool {
        return !(account == nil || wallets?.count == 0)
    }
    
    func registerCells() {
        let walletCell = UINib.init(nibName: "WalletTableViewCell", bundle: nil)
        self.assetsVC?.tableView.register(walletCell, forCellReuseIdentifier: "walletCell")
        
        let portfolioCell = UINib.init(nibName: "PortfolioTableViewCell", bundle: nil)
        self.assetsVC?.tableView.register(portfolioCell, forCellReuseIdentifier: "portfolioCell")
        
        let newWalletCell = UINib.init(nibName: "NewWalletTableViewCell", bundle: nil)
        self.assetsVC?.tableView.register(newWalletCell, forCellReuseIdentifier: "newWalletCell")
    }

    func getWalletsVerbose(completion: @escaping (_ flag: Bool) -> ()) {
//        blockUI()
        DataManager.shared.getWalletsVerbose() { (walletsArrayFromApi, err) in
//            self.unlockUI()
            if err != nil {
                return
            } else {
                let walletsArr = UserWalletRLM.initWithArray(walletsInfo: walletsArrayFromApi!)
                print("afterVerbose:rawdata: \(walletsArrayFromApi)")
                DataManager.shared.realmManager.updateWalletsInAcc(arrOfWallets: walletsArr, completion: { (acc, err) in
                    self.account = acc
                    print("wallets: \(acc?.wallets)")
                    completion(true)
                })
            }
        }
    }
    
    func getWalletVerboseForSockets(completion: @escaping (_ flag: Bool) -> ()) {
        if account == nil {
            return
        }
        DataManager.shared.getWalletsVerbose() { (walletsArrayFromApi, err) in
            if err != nil {
                return
            } else {
                let walletsArr = UserWalletRLM.initWithArray(walletsInfo: walletsArrayFromApi!)
                print("afterVerboseForSockets:rawdata: \(walletsArrayFromApi)")
                DataManager.shared.realmManager.updateWalletsInAcc(arrOfWallets: walletsArr, completion: { (acc, err) in
                    self.account = acc
                    print("wallets: \(acc?.wallets)")
                    completion(true)
                    DataManager.shared.getAccount(completion: { (acc, err) in
                        print("afterVerbose: \(acc!)")
                    })
                })
            }
        }
    }
    
    func getWalletViewController(indexPath: IndexPath) -> UIViewController {
        if wallets == nil {
            return UIViewController()
        }
        
        let wallet = wallets?[indexPath.row - 2]
        let storyboard = UIStoryboard(name: "Wallet", bundle: nil)
        assetsVC?.sendAnalyticsEvent(screenName: screenMain, eventName: "\(walletOpenWithChainTap)\(wallet!.chain)")
        
        switch wallet!.blockchainType.blockchain {
        case BLOCKCHAIN_BITCOIN:
            let vc = storyboard.instantiateViewController(withIdentifier: "WalletMainID") as! BTCWalletViewController
            vc.presenter.wallet = wallet
            vc.presenter.account = account
            
            return vc
        case BLOCKCHAIN_ETHEREUM:
            let vc = storyboard.instantiateViewController(withIdentifier: "EthWalletID") as! EthWalletViewController
            vc.presenter.wallet = wallet
            vc.presenter.account = account
            
            return vc
        default:
            return UIViewController()
        }
    }
    
    func blockUI() {
//        assetsVC!.loader.show(customTitle: assetsVC?.localize(string: Constants.gettingWalletString))
//        assetsVC!.progressHUD.blockUIandShowProgressHUD()
        assetsVC?.tableView.isUserInteractionEnabled = false
//        assetsVC?.tabBarController?.view.isUserInteractionEnabled = false
    }
    
    func unlockUI() {
//        assetsVC!.loader.hide()
//        assetsVC!.progressHUD.unblockUIandHideProgressHUD()
        assetsVC?.tableView.isUserInteractionEnabled = true
//        assetsVC?.tabBarController?.view.isUserInteractionEnabled = true
        assetsVC?.refreshControl.endRefreshing()
    }
    
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
    
    func createFirstWallets(blockchianType: BlockchainType, completion: @escaping (_ answer: String?,_ error: Error?) -> ()) {
        var binData : BinaryData = account!.binaryDataString.createBinaryData()!
        let createdWallet = UserWalletRLM()
        //MARK: topIndex
        let currencyID = blockchianType.blockchain.rawValue
        let networkID = blockchianType.net_type
        var currentTopIndex = account!.topIndexes.filter("currencyID = \(currencyID) AND networkID == \(networkID)").first
        
        if currentTopIndex == nil {
            //            mainVC?.presentAlert(with: "TopIndex error data!")
            currentTopIndex = TopIndexRLM.createDefaultIndex(currencyID: NSNumber(value: currencyID), networkID: NSNumber(value: networkID), topIndex: NSNumber(value: 0))
        }
        
        let dict = DataManager.shared.createNewWallet(for: &binData, blockchain: blockchianType, walletID: currentTopIndex!.topIndex.uint32Value)
        
        createdWallet.chain = NSNumber(value: currencyID)
        createdWallet.chainType = NSNumber(value: networkID)
        createdWallet.name = "My First \(blockchianType.shortName) Wallet"
        createdWallet.walletID = NSNumber(value: dict!["walletID"] as! UInt32)
        createdWallet.addressID = NSNumber(value: dict!["addressID"] as! UInt32)
        createdWallet.address = dict!["address"] as! String
        
        if createdWallet.blockchainType.blockchain == BLOCKCHAIN_ETHEREUM {
            createdWallet.ethWallet = ETHWallet()
            createdWallet.ethWallet?.balance = "0"
            createdWallet.ethWallet?.nonce = NSNumber(value: 0)
            createdWallet.ethWallet?.pendingWeiAmountString = "0"
        }
        
        let params = [
            "currencyID"    : currencyID,
            "networkID"     : networkID,
            "address"       : createdWallet.address,
            "addressIndex"  : createdWallet.addressID,
            "walletIndex"   : createdWallet.walletID,
            "walletName"    : createdWallet.name
            ] as [String : Any]
        
        guard assetsVC!.presentNoInternetScreen() else {
            self.assetsVC?.loader.hide()
            
            return
        }
        
        DataManager.shared.addWallet(params: params) { [unowned self] (dict, error) in
            self.assetsVC?.loader.hide()
            if error == nil {
                self.assetsVC!.sendAnalyticsEvent(screenName: screenCreateWallet, eventName: cancelTap)
                completion("ok", nil)
            } else {
                self.assetsVC?.presentAlert(with: self.assetsVC!.localize(string: Constants.errorWhileCreatingWalletString))
                completion(nil, nil)
            }
        }
    }
}
