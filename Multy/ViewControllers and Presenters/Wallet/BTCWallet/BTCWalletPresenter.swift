//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import UIKit
import RealmSwift

class BTCWalletPresenter: NSObject {
    var mainVC : BTCWalletViewController?
    var blockedAmount = UInt64(0)
    var wallet : UserWalletRLM? {
        didSet {
            mainVC?.titleLbl.text = self.wallet?.name
            mainVC?.collectionView.reloadData()
            blockedAmount = wallet!.calculateBlockedAmount()
            mainVC?.makeConstantsForAnimation()
        }
    }
    var account : AccountRLM?
    var historyArray = [HistoryRLM]() {
        didSet {
            reloadTableView()
        }
    }
    
    func reloadTableView() {
        if historyArray.count > 0 {
            mainVC?.hideEmptyLbls()
        }
        
        let contentOffset = mainVC!.tableView.contentOffset
        mainVC!.tableView.reloadData()
        mainVC!.tableView.layoutIfNeeded()
        mainVC!.tableView.setContentOffset(contentOffset, animated: false)
        
        self.mainVC!.refreshControl.endRefreshing()
    }
    
    func registerCells() {
        let walletHeaderCell = UINib.init(nibName: "MainWalletHeaderCell", bundle: nil)
        self.mainVC?.tableView.register(walletHeaderCell, forCellReuseIdentifier: "MainWalletHeaderCellID")
        
//        let walletCollectionCell = UINib.init(nibName: "MainWalletCollectionViewCell", bundle: nil)
//        self.mainVC?.tableView.register(walletCollectionCell, forCellReuseIdentifier: "WalletCollectionViewCellID")
        
        let transactionCell = UINib.init(nibName: "TransactionWalletCell", bundle: nil)
        self.mainVC?.tableView.register(transactionCell, forCellReuseIdentifier: "TransactionWalletCellID")
        
        let transactionPendingCell = UINib.init(nibName: "TransactionPendingCell", bundle: nil)
        self.mainVC?.tableView.register(transactionPendingCell, forCellReuseIdentifier: "TransactionPendingCellID")
        
        let headerCollectionCell = UINib.init(nibName: "MainWalletCollectionViewCell", bundle: nil)
        self.mainVC?.collectionView.register(headerCollectionCell, forCellWithReuseIdentifier: "MainWalletCollectionViewCellID")
    }
    
    func fixConstraints() {
        if #available(iOS 11.0, *) {
            //OK: Storyboard was made for iOS 11
        } else {
            self.mainVC?.tableViewTopConstraint.constant = 0
        }
    }
    
    func numberOfTransactions() -> Int {
        return self.historyArray.count
    }
    
    func isTherePendingMoney(for indexPath: IndexPath) -> Bool {
        return wallet!.blockedAmount(for: historyArray[indexPath.row]) > 0
    }
    
    func getNumberOfPendingTransactions() -> Int {
        var count = 0
        
        for transaction in historyArray {
            if wallet!.blockedAmount(for: transaction) > 0 {
                count += 1
            }
        }
        
        return count
    }
    

    func blockUI() {
        self.mainVC?.spiner.startAnimating()
        self.mainVC?.view.isUserInteractionEnabled = false
//        self.mainVC?.view.alpha = 0.3
    }
    
    func unlockUI() {
        self.mainVC?.spiner.stopAnimating()
        self.mainVC?.view.isUserInteractionEnabled = true
//        self.mainVC?.view.alpha = 1.0
    }
    
    func getHistoryAndWallet() {
        blockUI()
        DataManager.shared.getOneWalletVerbose(walletID: wallet!.walletID, blockchain: wallet!.blockchainType) { (wallet, error) in
            if wallet != nil {
                self.wallet = wallet
            }
        }
        
        DataManager.shared.getTransactionHistory(currencyID: wallet!.chain, networkID: wallet!.chainType, walletID: wallet!.walletID) { [unowned self] (histList, err) in
            self.unlockUI()
//            self.mainVC?.spiner.stopAnimating()
            if err == nil && histList != nil {
                self.mainVC!.refreshControl.endRefreshing()
                self.mainVC!.tableView.isUserInteractionEnabled = true
                self.mainVC!.tableView.contentOffset.y = 0
                self.historyArray = histList!.sorted(by: { $0.blockTime > $1.blockTime })
                print("transaction history:\n\(histList)")
                self.mainVC!.isSocketInitiateUpdating = false
            }
        }
    }
}
