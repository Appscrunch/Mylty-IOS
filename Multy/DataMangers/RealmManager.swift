//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class RealmManager: NSObject {
    static let shared = RealmManager()
    
    private var realm : Realm? = nil
    let schemaVersion : UInt64 = 12
    
    var account: AccountRLM?
    
    private override init() {
        super.init()
        
//        UserPreferences.shared.getAndDecryptDatabasePassword { (pass, error) in
//            if pass != nil {
//                _ = Realm.Configuration(encryptionKey: pass!.data(using: .utf8),
//                                        schemaVersion: self.schemaVersion,
//                                        migrationBlock: { migration, oldSchemaVersion in
//                                            if oldSchemaVersion < 7 {
//                                                self.migrateFrom6To7(with: migration)
//                                            }
//                                            if oldSchemaVersion < 8 {
//                                                self.migrateFrom7To8(with: migration)
//                                            }
//                                            if oldSchemaVersion < 9 {
//                                                self.migrateFrom8To9(with: migration)
//                                            }
//                }
//                )
//            } else {
//                print("Realm error while setting config")
//            }
//        }
    }
    
    public func finishRealmSession() {
        realm = nil
    }
    
    public func getRealm(completion: @escaping (_ realm: Realm?, _ error: NSError?) -> ()) {
        if realm != nil {
            completion(realm!, nil)
            
            return
        }
        
        UserPreferences.shared.getAndDecryptDatabasePassword { (pass, error) in
            guard pass != nil else {
                completion(nil, nil)
                
                return
            }
            
            let realmConfig = Realm.Configuration(encryptionKey: pass,
                                                  schemaVersion: self.schemaVersion,
                                                  migrationBlock: { migration, oldSchemaVersion in
                                                    if oldSchemaVersion < 7 {
                                                        self.migrateFrom6To7(with: migration)
                                                    }
                                                    if oldSchemaVersion < 8 {
                                                        self.migrateFrom7To8(with: migration)
                                                    }
                                                    if oldSchemaVersion < 9 {
                                                        self.migrateFrom8To9(with: migration)
                                                    }
                                                    if oldSchemaVersion < 10 {
                                                        self.migrateFrom9To10(with: migration)
                                                    }
                                                    if oldSchemaVersion < 11 {
                                                        self.migrateFrom10To11(with: migration)
                                                    }
                                                    if oldSchemaVersion < 12 {
                                                        self.migrateFrom11To12(with: migration)
                                                    }
                                                    if oldSchemaVersion < 13 {
                                                        self.migrateFrom12To13(with: migration)
                                                    }
            })
            
            do {
                let realm = try Realm(configuration: realmConfig)
                self.realm = realm
                
                completion(realm, nil)
            } catch let error as NSError {
                try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
                completion(nil, error)
                fatalError("Error opening Realm: \(error)")
            }
        }
    }
    
    public func getSeedPhrase(completion: @escaping (_ seedPhrase: String?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let seedPhraseOpt = realm.object(ofType: SeedPhraseRLM.self, forPrimaryKey: 1)
                
                if seedPhraseOpt == nil {
                    completion(nil, nil)
                } else {
                    completion(seedPhraseOpt!.seedString, nil)
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
    public func writeSeedPhrase(_ seedPhrase: String, completion: @escaping (_ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let seedPhraseOpt = realm.object(ofType: SeedPhraseRLM.self, forPrimaryKey: 1)
                
                try! realm.write {
                    //replace old value if exists
                    let seedRLM = seedPhraseOpt == nil ? SeedPhraseRLM() : seedPhraseOpt!
                    seedRLM.seedString = seedPhrase
                    
                    realm.add(seedRLM, update: true)
                    print("Successful writing seed phrase")
                }
            } else {
                print("Error fetching realm:\(#function)")
            }
        }
        
    }
    
    public func deleteSeedPhrase(completion: @escaping (_ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let seedPhraseOpt = realm.object(ofType: SeedPhraseRLM.self, forPrimaryKey: 1)
                
                if let seedPhrase = seedPhraseOpt {
                    try! realm.write {
                        realm.delete(seedPhrase)
                        
                        completion(nil)
                        print("Successful writing seed phrase")
                    }
                } else {
                    completion(NSError())
                    print("Error fetching seedPhrase")
                }
            } else {
                completion(NSError())
                print("Error fetching realm")
            }
        }
    }
    
    public func updateAccount(_ accountDict: NSDictionary, completion: @escaping (_ account : AccountRLM?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let account = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                
                try! realm.write {
                    //replace old value if exists
                    let accountRLM = account == nil ? AccountRLM() : account!
                    
                    if accountDict["expire"] != nil {
                        accountRLM.expireDateString = accountDict["expire"] as! String
                    }
                    
                    if accountDict["token"] != nil {
                        accountRLM.token = accountDict["token"] as! String
                    }
                    
                    if accountDict["userID"] != nil {
                        accountRLM.userID = accountDict["userID"] as! String
                    }
                    
                    if accountDict["deviceID"] != nil {
                        accountRLM.deviceID = accountDict["deviceID"] as! String
                    }
                    
                    if accountDict["pushToken"] != nil {
                        accountRLM.pushToken = accountDict["pushToken"] as! String
                    }
                    
                    if accountDict["seedPhrase"] != nil {
                        accountRLM.seedPhrase = accountDict["seedPhrase"] as! String
                    }
                    
                    if accountDict["binaryData"] != nil {
                        accountRLM.binaryDataString = accountDict["binaryData"] as! String
                    }
                    
                    if accountDict["topindexes"] != nil {
                        let newTopIndexes = TopIndexRLM.initWithArray(indexesArray: accountDict["topindexes"] as! NSArray)
                        accountRLM.topIndexes.removeAll()
                        for newIndex in newTopIndexes {
                            accountRLM.topIndexes.append(newIndex)
                        }
                    }
                    
                    //MARK: create topIndexes for all currencies
                    if accountRLM.topIndexes.count == 0 {
                        accountRLM.topIndexes.append(TopIndexRLM.createDefaultIndex(currencyID: 0, topIndex: 0))
                    }
                    
                    if accountDict["wallets"] != nil && !(accountDict["wallets"] is NSNull) {
                        let walletsList = accountDict["wallets"] as! List<UserWalletRLM>
                        
                        for wallet in walletsList {
                            let walletFromDB = realm.object(ofType: UserWalletRLM.self, forPrimaryKey: wallet.id)
                            
                            if walletFromDB != nil {
                                realm.add(wallet, update: true)
                            } else {
                                accountRLM.wallets.append(wallet)
                            }
                        }
                        
                        accountRLM.walletCount = NSNumber(value: accountRLM.wallets.count)
                    }
                    
                    realm.add(accountRLM, update: true)
                    self.account = accountRLM
                    
                    completion(accountRLM, nil)
                    
                    print("Successful writing account: \(accountRLM)")
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
//     public func updateAccount(_ accountDict: NSDictionary, completion: @escaping (_ account : AccountRLM?, _ error: NSError?) -> ()) {
//    public func updateAccountWallets(_ wallets) {
//        
//    }
    
    public func createWallet(_ walletDict: Dictionary<String, Any>, completion: @escaping (_ account : UserWalletRLM?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let wallet = UserWalletRLM.initWithInfo(walletInfo: NSDictionary(dictionary: walletDict))
                
                try! realm.write {
                    realm.add(wallet, update: true)
                    
                    completion(wallet, nil)
                    
                    print("Successful writing wallet")
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
    public func updateExchangePrice(_ ratesDict: NSDictionary, completion: @escaping (_ exchangePrice : ExchangePriceRLM?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let exchange = ExchangePriceRLM.initWithInfo(info: ratesDict)
                
                try! realm.write {
                    realm.add(exchange, update: true)

                    completion(exchange, nil)

                    print("Successful writing exchange price")
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
    public func getExchangePrice(completion: @escaping (_ exchangePrice : ExchangePriceRLM?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let prices = realm.object(ofType: ExchangePriceRLM.self, forPrimaryKey: 1)
                
                if prices != nil {
                    completion(prices, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
    public func getAccount(completion: @escaping (_ account: AccountRLM?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                if acc != nil {
                    self.account = acc!
                    completion(acc!, nil)
                } else {
                    completion(nil, nil)
                }
            } else {
                print("Err from realm GetAcctount:\(#function)")
                completion(nil,nil)
            }
        }
    }
    
    public func clearSeedPhraseInAcc() {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                try! realm.write {
                    acc?.seedPhrase = ""
                    print("Seed phrase was deleted from db by realm Manager")
                }
            }
        }
    }
    
    public func createOrUpdateAccount(accountInfo: NSArray, completion: @escaping(_ account: AccountRLM?, _ error: NSError?)->()) {
        getRealm { (realmOpt, err) in
            guard let realm = realmOpt else {
                completion(nil, nil)
                
                return
            }
            
            let account = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
            
            guard account != nil else {
                completion(nil, nil)
                
                return
            }
            
            let accountWallets = account!.wallets
            let newWallets = List<UserWalletRLM>()
            
            for wallet in accountInfo {
                let wallet = wallet as! NSDictionary
                let walletID = wallet["WalletIndex"] != nil ? wallet["WalletIndex"] : wallet["walletindex"]
                
                let modifiedWallet = accountWallets.filter("walletID = \(walletID)").first

                try! realm.write {
//                    if modifiedWallet != nil {
//                        modifiedWallet!.addresses = wallet.addresses
//                        newWallets.append(modifiedWallet!)
//                    } else {
//                        newWallets.append(wallet)
//                    }
                }
            }
            
            try! realm.write {
                account!.wallets.removeAll()
                for wallet in newWallets {
                    account!.wallets.append(wallet)
                    
                    account!.wallets.last!.addresses.removeAll()
                    for address in wallet.addresses {
                        account!.wallets.last!.addresses.append(address)
                        
                        account!.wallets.last!.addresses.last!.spendableOutput.removeAll()
                        for ouput in address.spendableOutput {
                            account?.wallets.last!.addresses.last!.spendableOutput.append(ouput)
                        }
                    }
                }
                
                //                        acc!.wallets = newWallets
                //                        acc?.wallets = arrOfWallets
                
                self.account = account
                
                completion(account, nil)
            }
        }
    }
    
    public func updateWalletsInAcc(arrOfWallets: List<UserWalletRLM>, completion: @escaping(_ account: AccountRLM?, _ error: NSError?)->()) {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                if acc != nil {
                    let accWallets = acc!.wallets
                    let newWallets = List<UserWalletRLM>()
                    
                    for wallet in arrOfWallets {
                        let modifiedWallet = accWallets.filter("walletID = \(wallet.walletID)").first
                        
                        try! realm.write {
                            if modifiedWallet != nil {
                                modifiedWallet?.name = wallet.name
                                modifiedWallet!.addresses = wallet.addresses

                                for (index,address) in wallet.addresses.enumerated() {
//                                    modifiedWallet!.addresses[index].spendableOutput.removeAll()
//                                    for out in address.spendableOutput {
//                                        modifiedWallet!.addresses[index].spendableOutput.append(out)
//                                    }
                                }
                                
//                                for address in wallet.addresses {
//
//                                    for output in address.spendableOutput {
//                                        modifiedWallet!.addresses.last!.spendableOutput.append(output)
//                                    }
//                                }
                                
                                newWallets.append(modifiedWallet!)
                            } else {
                                newWallets.append(wallet)
                            }
                        }
                    }
                    
                    //append wallets without spendOut
//                    for wallet in accWallets {
//                        let unmodifiedWallet = newWallets.filter("walletID = \(wallet.walletID)").first
//
//                        if (unmodifiedWallet == nil) {
//                            newWallets.append(wallet)
//                        }
//                    }
                    
                    try! realm.write {
                        acc!.wallets.removeAll()
                        for wallet in newWallets {
                            acc!.wallets.append(wallet)
                            
                            acc!.wallets.last!.addresses.removeAll()
                            //MARK: CHECK THIS    deleting addresses    Check addressID and delete existing
                            for address in wallet.addresses {
//                                let modifiedAddress = wallet.address.filter("addressID = \(wallet.addressID)").first

                                acc!.wallets.last!.addresses.append(address)
//                                acc!.wallets.last!.addresses.last!.spendableOutput.removeAll()
//                                for ouput in address.spendableOutput {
//                                    acc?.wallets.last!.addresses.last!.spendableOutput.append(ouput)
//                                }
                            }
                        }
//                        acc!.wallets = newWallets
//                        acc?.wallets = arrOfWallets
                        completion(acc, nil)
                    }
                } else {
                    completion(nil, err)
                }
            }
        }
    }
    
    public func clearRealm() {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                try! realm.write {
                    realm.deleteAll()
                }
            }
        }
        
        self.account = nil
    }
    
    // MARK: - Migrations
    func migrateFrom6To7(with migration: Migration) {
        migration.enumerateObjects(ofType: SpendableOutputRLM.className()) { (_, newSpendOut) in
            newSpendOut?["addressID"] = NSNumber(value: 0)
        }
    }
    
    func migrateFrom7To8(with migration: Migration) {
        migration.enumerateObjects(ofType: AccountRLM.className()) { (_, newAccount) in
            newAccount?["backupSeedPhrase"] = ""
        }
    }
    
    func migrateFrom8To9(with migration: Migration) {
        migration.enumerateObjects(ofType: AccountRLM.className()) { (_, newAccount) in
            newAccount?["topIndex"] = NSNumber(value: 0)
        }
    }
    
    func migrateFrom9To10(with migration: Migration) {
        migration.enumerateObjects(ofType: SpendableOutputRLM.className()) { (_, newSpendableOutput) in
            newSpendableOutput?["txStatus"] = ""
        }
    }
    
    func migrateFrom10To11(with migration: Migration) {
        migration.enumerateObjects(ofType: HistoryRLM.className()) { (oldHistoryRLM, newHistoryRLM) in
            newHistoryRLM?["walletIndex"] = NSNumber(value: oldHistoryRLM?["walletIndex"] as? Int ?? 0)
        }
        
        migration.enumerateObjects(ofType: SpendableOutputRLM.className()) { (oldOutput, newOutput) in
            newOutput?["transactionStatus"] = oldOutput?["txStatus"]
        }
    }
    
    func migrateFrom11To12(with migration: Migration) {
        migration.enumerateObjects(ofType: HistoryRLM.className()) { (oldHistoryRLM, newHistoryRLM) in
            if let intStatus = Int(oldHistoryRLM?["txStatus"] as! String) {
                newHistoryRLM?["txStatus"] = NSNumber(value: intStatus)
            } else {
                newHistoryRLM?["txStatus"] = NSNumber(value: 0)
            }
        }
    }
    
    func migrateFrom12To13(with migration: Migration) {
        migration.enumerateObjects(ofType: AddressRLM.className()) { (_, newAddress) in
            newAddress?["lastActionDate"] = Date()
        }
    }
    
    //Greedy algorithm
    func spendableOutput(addresses: List<AddressRLM>) -> [SpendableOutputRLM] {
        let ouputs = List<SpendableOutputRLM>()
        
        for address in addresses {
            //add checking output (in/out)
            
            for out in address.spendableOutput {
                ouputs.append(out)
            }
        }
        
        let results = ouputs.sorted(by: { (out1, out2) -> Bool in
            out1.transactionOutAmount.uint32Value > out2.transactionOutAmount.int32Value
        })
        
        return results
    }
    
    func spendableOutput(wallet: UserWalletRLM) -> [SpendableOutputRLM] {
        let ouputs = List<SpendableOutputRLM>()
        
        let addresses = wallet.addresses
        for address in addresses {
            //add checking output (in/out)
            
            for out in address.spendableOutput {
                ouputs.append(out)
            }
        }
        
        let results = ouputs.sorted(by: { (out1, out2) -> Bool in
            out1.transactionOutAmount.uint32Value > out2.transactionOutAmount.int32Value
        })
        
        return results
    }
    
    func greedySubSet(outputs: [SpendableOutputRLM], threshold: UInt32) -> [SpendableOutputRLM] {
        var sum = spendableOutputSum(outputs: outputs)
        var result = outputs
        
        if sum < threshold {
            return [SpendableOutputRLM]()
        }
        
        var index = 0
        while index < result.count {
            let output = result[index]
            if sum > threshold + output.transactionOutAmount.uint32Value {
                sum = sum - output.transactionOutAmount.uint32Value
                result.remove(at: index)
            } else {
                index += 1
            }
        }
        
        return result
    }
    
    func spendableOutputSum(outputs: [SpendableOutputRLM]) -> UInt32 {
        var sum = UInt32(0)
        
        for output in outputs {
            sum += output.transactionOutAmount.uint32Value
        }
        
        return sum
    }
    
    func saveHistoryForWallet(historyArr: List<HistoryRLM>, completion: @escaping(_ historyArr: List<HistoryRLM>?) -> ()) {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                try! realm.write {
                    let oldHistoryObjects = realm.objects(HistoryRLM.self)
                    
                    for obj in historyArr {
                        //add checking for repeated tx and updated status
                        let repeatedObj = oldHistoryObjects.filter("txHash = \(obj.txHash)").first
                        if repeatedObj != nil {
                            if shouldUpdate(fromStatus: repeatedObj!.txStatus.intValue,
                                            toStatus: obj.txStatus.intValue) {
                                realm.add(obj, update: true)
                            }
                        } else {
                            realm.add(obj, update: true)
                        }
                    }
                    completion(historyArr)
                }
            } else {
                print("Err from realm GetAcctount:\(#function)")
                completion(nil)
            }
        }
    }
    
    func getTransactionHistoryBy(walletIndex: Int, completion: @escaping(_ arrOfHist: Results<HistoryRLM>?) -> ()) {
        getRealm { (realmOpt, err) in
//            if let realm = realmOpt {
//                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
//                if acc != nil {
//                    completion(acc, nil)
//                } else {
//                    completion(nil, nil)
//                }
//            } else {
//                print("Err from realm GetAcctount:\(#function)")
//                completion(nil,nil)
//            }
            if let realm = realmOpt {
                let allHistoryObjects = realm.objects(HistoryRLM.self).filter("walletIndex = \(walletIndex)")
                if !allHistoryObjects.isEmpty {
                    completion(allHistoryObjects)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getWallet(walletID: NSNumber, completion: @escaping(_ wallet: UserWalletRLM?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let primaryKey = generateWalletPrimaryKey(currencyID: 0, walletID: walletID.uint32Value)
                let wallet = realm.object(ofType: UserWalletRLM.self, forPrimaryKey: primaryKey)
                
                completion(wallet)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchAddressesForWalllet(walletID: NSNumber, completion: @escaping(_ : [String]?) -> ()) {
        getWallet(walletID: walletID) { (wallet) in
            if wallet != nil {
                var addresses = [String]()
                wallet!.addresses.forEach({ addresses.append($0.address) })
                completion(addresses)
            } else {
                completion(nil)
            }
        }
    }
}
