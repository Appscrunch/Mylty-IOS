//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class UserWalletRLM: Object {
    @objc dynamic var id = String()    //
    @objc dynamic var chain = NSNumber(value: 0)    //UInt32
    @objc dynamic var walletID = NSNumber(value: 0) //UInt32
    @objc dynamic var addressID = NSNumber(value: 0) //UInt32
    
    @objc dynamic var privateKey = String()
    @objc dynamic var publicKey = String()
    
    @objc dynamic var name = String()
    @objc dynamic var cryptoName = String()  //like BTC
    @objc dynamic var sumInCrypto: Double = 0.0 {
        didSet {
            sumInFiat = sumInCrypto * exchangeCourse
        }
    }
    
    @objc dynamic var sumInFiat: Double = 0.0
    
    @objc dynamic var fiatName = String()
    @objc dynamic var fiatSymbol = String()
    
    @objc dynamic var address = String()
    
    @objc dynamic var historyAddress : AddressRLM?
    
    var addresses = List<AddressRLM>() {
        didSet {
            var sum : UInt32 = 0
            
            for address in addresses {
//                for out in address.spendableOutput {
//                    sum += out.transactionOutAmount.uint32Value
//                }
                for out in address.spendableOutput {
                    sum += out.transactionOutAmount.uint32Value
                }
            }
            
            sumInCrypto = convertSatoshiToBTC(sum: sum)
            
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
        
        if let chain = walletInfo["currencyid"]  {
            wallet.chain = NSNumber(value: chain as! UInt32)
        }
        
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
        
        //MARK: temporary only 0-currency
        //MARK: server BUG: WalletIndex and walletindex
        //No data from server
        if walletInfo["walletindex"] != nil || walletInfo["WalletIndex"] != nil {
            wallet.id = generateWalletPrimaryKey(currencyID: 0, walletID: wallet.walletID.uint32Value)
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
        
        self.cryptoName = "BTC"
        self.fiatName = "USD"
        self.fiatSymbol = "$"
    }
    
    public func fetchAddresses() -> [String] {
        var addresses = [String]()
        self.addresses.forEach({ addresses.append($0.address) })
        
        return addresses
    }
    
    func calculateBlockedAmount() -> UInt32 {
        var sum = UInt32(0)
        
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue {
                    sum += out.transactionOutAmount.uint32Value
                }/* else if out.transactionStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
                    let addresses = self.fetchAddresses()
                    
                    if addresses.contains(address.address) {
                        sum += out.transactionOutAmount.uint32Value
                    }
                }*/
            }
        }
        
        return sum
    }
    
    func availableAmount() -> UInt32 {
        var sum = UInt32(0)
        
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.BlockIncoming.rawValue {
                    sum += out.transactionOutAmount.uint32Value
                }/* else if out.transactionStatus.intValue == TxStatus.MempoolOutcoming.rawValue {
                 let addresses = self.fetchAddresses()
                 
                 if addresses.contains(address.address) {
                 sum += out.transactionOutAmount.uint32Value
                 }
                 }*/
            }
        }
        
        return sum
    }
    
    func isTherePendingAmount() -> Bool {
        for address in self.addresses {
            for out in address.spendableOutput {
                if out.transactionStatus.intValue == TxStatus.MempoolIncoming.rawValue && out.transactionOutAmount.uint32Value > 0 {
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
