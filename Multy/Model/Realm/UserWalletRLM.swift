//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

private typealias WalletUpdateRLM = UserWalletRLM

class UserWalletRLM: Object {
    @objc dynamic var id = String()    //
    @objc dynamic var chain = NSNumber(value: 0)    //UInt32
    @objc dynamic var chainType = NSNumber(value: 1)    //UInt32//BlockchainNetType
    @objc dynamic var walletID = NSNumber(value: 0) //UInt32
    @objc dynamic var addressID = NSNumber(value: 0) //UInt32
    
    @objc dynamic var privateKey = String()
    @objc dynamic var publicKey = String()
    
    @objc dynamic var name = String()
    @objc dynamic var cryptoName = String()  //like BTC
    @objc dynamic var sumInCrypto: Double = 0.0
    
    var sumInCryptoString: String {
        get {
            switch blockchain.blockchain {
            case BLOCKCHAIN_BITCOIN:
                return sumInCrypto.fixedFraction(digits: 8)
            case BLOCKCHAIN_ETHEREUM:
                return ethWallet!.balance.appendDelimeter(at: 18)
            default:
                return ""
            }
        }
    }
    
    var blockchain: BlockchainType {
        get {
            return BlockchainType.create(wallet: self)
        }
    }
    
    var availableSumInCrypto: Double {
        get {
            if self.blockchain.blockchain == BLOCKCHAIN_BITCOIN {
                return availableAmount().btcValue
            } else {
                return 0
            }
        }
    }
    
    var sumInFiat: Double {
        get {
            if self.blockchain.blockchain == BLOCKCHAIN_BITCOIN {
                return sumInCrypto * exchangeCourse
            } else {
                return Double(ethWallet!.balance.appendDelimeter(at: 18).replacingOccurrences(of: ",", with: "."))! * exchangeCourse
            }
        }
    }
    
    var sumInFiatString: String {
        get {
            return sumInFiat.fixedFraction(digits: 2)
        }
    }
    
    @objc dynamic var fiatName = String()
    @objc dynamic var fiatSymbol = String()
    
    @objc dynamic var address = String()
    
    @objc dynamic var historyAddress : AddressRLM?
    
    @objc dynamic var isTherePendingTx = NSNumber(value: 0)
    
    @objc dynamic var ethWallet: ETHWallet?
    @objc dynamic var btcWallet: BTCWallet?
        
    var exchangeCourse: Double {
        get {
            return DataManager.shared.makeExchangeFor(blockchainType: blockchain)
        }
    }
    
    var addresses = List<AddressRLM>() {
        didSet {
            var sum : UInt64 = 0
            
            for address in addresses {
                for out in address.spendableOutput {
                    sum += out.transactionOutAmount.uint64Value
                }
            }
            
            sumInCrypto = sum.btcValue
            
            address = addresses.last?.address ?? ""
        }
    }
    
    public class func initWithArray(walletsInfo: NSArray) -> List<UserWalletRLM> {
        let wallets = List<UserWalletRLM>()
        
        for walletInfo in walletsInfo {
            let wallet = UserWalletRLM.initWithInfo(walletInfo: walletInfo as! NSDictionary)
            wallets.append(wallet)
        }
        
        return wallets
    }
    
    public class func initWithInfo(walletInfo: NSDictionary) -> UserWalletRLM {
        let wallet = UserWalletRLM()
        wallet.ethWallet = ETHWallet()
        wallet.btcWallet = BTCWallet()
        
        if let chain = walletInfo["currencyid"]  {
            wallet.chain = NSNumber(value: chain as! UInt32)
        }
        
        if let chainType = walletInfo["networkid"]  {
            wallet.chainType = NSNumber(value: chainType as! UInt32)
        }
        
        //parse addition info for each chain
        wallet.updateSpecificInfo(from: walletInfo)
        
        //MARK: to be deleted
        if let walletID = walletInfo["WalletIndex"]  {
            wallet.walletID = NSNumber(value: walletID as! UInt32)
        }
        
        if let walletID = walletInfo["walletindex"]  {
            wallet.walletID = NSNumber(value: walletID as! UInt32)
        }
        
        if let walletName = walletInfo["walletname"] {
            wallet.name = walletName as! String
        }
        
        if let isTherePendingTx = walletInfo["pending"] as? Bool {
            wallet.isTherePendingTx = NSNumber(booleanLiteral: isTherePendingTx)
        }
        
        //MARK: temporary only 0-currency
        //MARK: server BUG: WalletIndex and walletindex
        //No data from server
        if walletInfo["walletindex"] != nil || walletInfo["WalletIndex"] != nil {
            wallet.id = DataManager.shared.generateWalletPrimaryKey(currencyID: wallet.chain.uint32Value, networkID: wallet.chainType.uint32Value, walletID: wallet.walletID.uint32Value)
        }
        
        wallet.updateWalletWithInfo(walletInfo: walletInfo)
        
        return wallet
    }
    
    public func updateWalletWithInfo(walletInfo: NSDictionary) {
        //MARK: to be deleted
        if let addresses = walletInfo["Adresses"] {
            self.addresses = AddressRLM.initWithArray(addressesInfo: addresses as! NSArray)
        }
        
        if let address = walletInfo["address"] as? NSDictionary {
            self.historyAddress = AddressRLM.initWithInfo(addressInfo: address)
        }
        
        if let addresses = walletInfo["addresses"] {
            if !(addresses is NSNull) {
                self.addresses = AddressRLM.initWithArray(addressesInfo: addresses as! NSArray)
            }
        }
        
        if let name = walletInfo["WalletName"] {
            self.name = name as! String
        }
        
        let blockchainType = BlockchainType.create(wallet: self)
        
        self.cryptoName = blockchainType.shortName
        self.fiatName = "USD"
        self.fiatSymbol = "$"
    }
    
    public func fetchAddresses() -> [String] {
        var addresses = [String]()
        self.addresses.forEach({ addresses.append($0.address) })
        
        return addresses
    }
    
    func calculateBlockedAmount() -> UInt64 {
        var sum = UInt64(0)
        
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue {
                    sum += out.transactionOutAmount.uint64Value
                }/* else if out.transactionStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
                    let addresses = self.fetchAddresses()
                    
                    if addresses.contains(address.address) {
                        sum += out.transactionOutAmount.uint64Value
                    }
                }*/
            }
        }
        
        return sum
    }
    
    func availableAmount() -> UInt64 {
        var sum = UInt64(0)
        
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.BlockIncoming.rawValue {
                    sum += out.transactionOutAmount.uint64Value
                }/* else if out.transactionStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
                 let addresses = self.fetchAddresses()
                 
                 if addresses.contains(address.address) {
                 sum += out.transactionOutAmount.uint64Value
                 }
                 }*/
            }
        }
        
        return sum
    }
    
    func blockedAmount(for transaction: HistoryRLM) -> UInt64 {
        var sum = UInt64(0)
        
        if transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            sum += transaction.txOutAmount.uint64Value
        } else if transaction.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            let addresses = self.fetchAddresses()
            
            for tx in transaction.txOutputs {
                if addresses.contains(tx.address) {
                    sum += tx.amount.uint64Value
                }
            }
        }
        
        return sum
    }
    
    func outgoingAmount(for transaction: HistoryRLM) -> UInt64 {
        var allSum = UInt64(0)
        var ourSum = UInt64(0)
        
        for tx in transaction.txInputs {
            allSum += tx.amount.uint64Value
        }
        
        let addresses = self.fetchAddresses()
        
        for tx in transaction.txOutputs {
            if addresses.contains(tx.address) {
                ourSum += tx.amount.uint64Value
            }
        }
        
        return allSum - ourSum
    }
    
    func isTransactionPending(for transaction: HistoryRLM) -> Bool {
        if transaction.txStatus.intValue == TxStatus.MempoolIncoming.rawValue {
            return true
        } else if transaction.txStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
            return true
        }
        
        return false
    }
    
    func isTherePendingAmount() -> Bool {
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue && out.transactionOutAmount.uint64Value > 0 {
                    return true
                }
            }
        }
        
        return false
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["availableSumInCrypto", "availableSumInFiat"]
    }
    
//    public func updateWallet(walletInfo: NSDictionary) {
//        
//        if let addresses = walletInfo["Adresses"] {
//            self.addresses = AddressRLM.initWithArray(addressesInfo: addresses as! NSArray)
//        }
//        
//        if let addresses = walletInfo["addresses"] {
//            if !(addresses is NSNull) {
//                for address in addresses {
//                    let address = address as! NSDictionary
//                    let addressID = address["addressIndex"] != nil ? address["addressindex"] : address["walletindex"]
//                    
//                    let modifiedWallet = accountWallets.filter("walletID = \(walletID)").first
//                }
//                
//                self.addresses = AddressRLM.initWithArray(addressesInfo: addresses as! NSArray)
//            }
//        }
//        
//        if let name = walletInfo["WalletName"] {
//            self.name = name as! String
//        }
//        
//        self.cryptoName = "BTC"
//        self.fiatName = "USD"
//        self.fiatSymbol = "$"
//    }
}

extension WalletUpdateRLM {
    func updateSpecificInfo(from infoDict: NSDictionary) {
        switch self.chain.uint32Value {
        case BLOCKCHAIN_BITCOIN.rawValue:
            break
        case BLOCKCHAIN_ETHEREUM.rawValue:
            updateETHWallet(from: infoDict)
        default:
            break
        }
    }
    
    
    func updateBTCWallet(from infoDict: NSDictionary) {
        
    }
    
    func updateETHWallet(from infoDict: NSDictionary) {
        if let balance = infoDict["balance"] as? String {
            self.ethWallet = ETHWallet()
            self.ethWallet!.balance = balance
        }
        
        if let nonce = infoDict["nonce"] as? NSNumber {
            self.ethWallet?.nonce = nonce
        }
        
        if let pendingBalance = infoDict["pendingbalance"] as? String {
            self.ethWallet!.pendingWeiAmountString = pendingBalance
        }
    }
}
