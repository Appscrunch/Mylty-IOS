//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias RealmMigrationManager = RealmManager

class RealmManager: NSObject {
    static let shared = RealmManager()
    
    private var realm : Realm? = nil
    let schemaVersion : UInt64 = 19
    
    var account: AccountRLM?
    
    private override init() {
        super.init()
    }
    
    public func finishRealmSession() {
        realm = nil
    }
    
    public func getRealm(completion: @escaping (_ realm: Realm?, _ error: NSError?) -> ()) {
        if realm != nil {
            completion(realm!, nil)
            
            return
        }
        
        UserPreferences.shared.getAndDecryptDatabasePassword { [weak self] (pass, error) in
            guard pass != nil else {
                completion(nil, nil)
                
                return
            }
            
            let realmConfig = Realm.Configuration(encryptionKey: pass,
                                                  schemaVersion: self!.schemaVersion,
                                                  migrationBlock: { migration, oldSchemaVersion in
                                                    if oldSchemaVersion < 7 {
                                                        self!.migrateFrom6To7(with: migration)
                                                    }
                                                    if oldSchemaVersion < 8 {
                                                        self!.migrateFrom7To8(with: migration)
                                                    }
                                                    if oldSchemaVersion < 9 {
                                                        self!.migrateFrom8To9(with: migration)
                                                    }
                                                    if oldSchemaVersion < 10 {
                                                        self!.migrateFrom9To10(with: migration)
                                                    }
                                                    if oldSchemaVersion < 11 {
                                                        self!.migrateFrom10To11(with: migration)
                                                    }
                                                    if oldSchemaVersion < 12 {
                                                        self!.migrateFrom11To12(with: migration)
                                                    }
                                                    if oldSchemaVersion < 13 {
                                                        self!.migrateFrom12To13(with: migration)
                                                    }
                                                    if oldSchemaVersion < 14 {
                                                        self!.migrateFrom13To14(with: migration)
                                                    }
                                                    if oldSchemaVersion < 15 {
                                                        self!.migrateFrom14To15(with: migration)
                                                    }
                                                    if oldSchemaVersion < 16 {
                                                        self!.migrateFrom15To16(with: migration)
                                                    }
                                                    if oldSchemaVersion < 17 {
                                                        self!.migrateFrom16To17(with: migration)
                                                    }
                                                    if oldSchemaVersion < 18 {
                                                        self!.migrateFrom17To18(with: migration)
                                                    }
                                                    if oldSchemaVersion < 19 {
                                                        self!.migrateFrom18To19(with: migration)
                                                    }
                                                    if oldSchemaVersion < 20 {
                                                        self!.migrateFrom19To20(with: migration)
                                                    }
            })
            
            do {
                let realm = try Realm(configuration: realmConfig)
                self!.realm = realm
                
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
        getRealm { [weak self] (realmOpt, error) in
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
                    
                    if accountDict["backupSeedPhrase"] != nil {
                        accountRLM.backupSeedPhrase = accountDict["backupSeedPhrase"] as! String
                    }
                    
                    if accountDict["binaryData"] != nil {
                        accountRLM.binaryDataString = accountDict["binaryData"] as! String
                    }
                    
                    if accountDict["topindexes"] != nil {
                        let newTopIndexes = TopIndexRLM.initWithArray(indexesArray: accountDict["topindexes"] as! NSArray)
                        accountRLM.topIndexes.removeAll()
                        self!.deleteTopIndexes(from: realm)
                        for newIndex in newTopIndexes {
                            accountRLM.topIndexes.append(newIndex)
                        }
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
                    self!.account = accountRLM
                    
                    completion(accountRLM, nil)
                    
                    print("Successful writing account: \(accountRLM)")
                }
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
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
        getRealm { [weak self] (realmOpt, err) in
            if let realm = realmOpt {
                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                if acc != nil {
                    self!.account = acc!
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
        getRealm { [weak self] (realmOpt, err) in
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
                
                self!.account = account
                
                completion(account, nil)
            }
        }
    }
    
    public func updateWalletsInAcc(arrOfWallets: List<UserWalletRLM>, completion: @escaping(_ account: AccountRLM?, _ error: NSError?)->()) {
        getRealm { [weak self] (realmOpt, err) in
            if let realm = realmOpt {
                let acc = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                if acc != nil {
                    let accWallets = acc!.wallets
                    let newWallets = List<UserWalletRLM>()
                    
                    for wallet in arrOfWallets {
                        let modifiedWallet = accWallets.filter("walletID = \(wallet.walletID) AND chain = \(wallet.chain) AND chainType = \(wallet.chainType)").first
                        
                        try! realm.write {
                            if modifiedWallet != nil {
                                modifiedWallet?.name =              wallet.name
                                modifiedWallet!.addresses =         wallet.addresses
                                modifiedWallet!.isTherePendingTx =  wallet.isTherePendingTx
                                modifiedWallet!.btcWallet =         wallet.btcWallet
                                modifiedWallet!.ethWallet =         wallet.ethWallet
                                modifiedWallet?.lastActivityTimestamp = wallet.lastActivityTimestamp

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
                            
                            self!.deleteAddressesAndSpendableInfo(acc!.wallets.last!.addresses, from: realm)
//                            self!.renewCustomWallets(in: acc!.wallets.last!, from: wallet, for: realm)
                            
                            acc!.wallets.last!.addresses.removeAll()
                            
                            //MARK: CHECK THIS    deleting addresses    Check addressID and delete existing
                            for address in wallet.addresses {
                                acc!.wallets.last!.addresses.append(address)
                            }
                        }

                        completion(acc, nil)
                    }
                } else {
                    completion(nil, err)
                }
            }
        }
    }
    
    public func clearRealm(completion: @escaping(_ ok: String?, _ error: Error?) -> ()) {
        getRealm { (realmOpt, err) in
            if err != nil {
                completion(nil, err)
                return
            }
            if let realm = realmOpt {
                try! realm.write {
                    realm.deleteAll()
                    completion("ok", nil)
                }
            }
            
        }
        
        account = nil
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
            out1.transactionOutAmount.uint64Value > out2.transactionOutAmount.int64Value
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
            out1.transactionOutAmount.uint64Value > out2.transactionOutAmount.int64Value
        })
        
        return results
    }
    
    func greedySubSet(outputs: [SpendableOutputRLM], threshold: UInt64) -> [SpendableOutputRLM] {
        var sum = spendableOutputSum(outputs: outputs)
        var result = outputs
        
        if sum < threshold {
            return [SpendableOutputRLM]()
        }
        
        var index = 0
        while index < result.count {
            let output = result[index]
            if sum > threshold + output.transactionOutAmount.uint64Value {
                sum = sum - output.transactionOutAmount.uint64Value
                result.remove(at: index)
            } else {
                index += 1
            }
        }
        
        return result
    }
    
    func spendableOutputSum(outputs: [SpendableOutputRLM]) -> UInt64 {
        var sum = UInt64(0)
        
        for output in outputs {
            sum += output.transactionOutAmount.uint64Value
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
                            realm.add(obj, update: true)
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
                let primaryKey = DataManager.shared.generateWalletPrimaryKey(currencyID: 0, networkID: 0, walletID: walletID.uint32Value)
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
    
    func fetchBTCWallets(isTestNet: Bool, completion: @escaping(_ wallets: [UserWalletRLM]?) -> ()) {
        getRealm { (realmOpt, err) in
            if let realm = realmOpt {
                let wallets = realm.objects(UserWalletRLM.self).filter("chainType = \(isTestNet.intValue) AND chain = \(BLOCKCHAIN_BITCOIN.rawValue)")
                let walletsArr = Array(wallets.sorted(by: {$0.availableSumInCrypto > $1.availableSumInCrypto}))
                
                completion(walletsArr)
            }
        }
    }
    
    func updateCurrencyExchangeRLM(curExchange: CurrencyExchange) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
//                let currencyExchange = realm.object(ofType: CurrencyExchangeRLM.self, forPrimaryKey: 1)
                let curRlm = CurrencyExchangeRLM()
                curRlm.createCurrencyExchange(currencyExchange: curExchange)
                try! realm.write {
//                    curRlm.btcToUSD = DataManager.shared.currencyExchange.btcToUSD
//                    curRlm.btcToUSD = DataManager.shared.currencyExchange.ethToUSD
                    realm.add(curRlm, update: true)
                }
            } else {
                print("Error fetching realm:\(#function)")
            }
        }
    }
    
    func fetchCurrencyExchange(completion: @escaping(_ curExhange: CurrencyExchangeRLM?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let currencyExchange = realm.object(ofType: CurrencyExchangeRLM.self, forPrimaryKey: 1)
                completion(currencyExchange)
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil)
            }
        }
    }
    
    func deleteTopIndexes(from realm: Realm) {
        let topIndexObjects = realm.objects(TopIndexRLM.self)
        realm.delete(topIndexObjects)
    }

    func deleteAddressesAndSpendableInfo(_ addresses: List<AddressRLM>,  from realm: Realm) {
        for address in addresses {
            realm.delete(address.spendableOutput)
            realm.delete(address)
        }
    }
    
    func renewCustomWallets(in wallet: UserWalletRLM, from newWallet: UserWalletRLM, for realm: Realm) {
        if wallet.ethWallet != nil {
            realm.delete(wallet.ethWallet!)
        }
        
        if wallet.btcWallet != nil {
            realm.delete(wallet.btcWallet!)
        }
        
        if newWallet.btcWallet != nil {
            realm.add(newWallet.btcWallet!)
        }
        
        if newWallet.ethWallet != nil {
            realm.add(newWallet.ethWallet!)
        }
        
        wallet.ethWallet = newWallet.ethWallet
        wallet.btcWallet = newWallet.btcWallet
    }
    
    func writeOrUpdateRecentAddress(blockchainType: BlockchainType, address: String, date: Date) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                try! realm.write {
                    if let recentAddress = realm.object(ofType: RecentAddressesRLM.self, forPrimaryKey: address) {
                        recentAddress.lastActionDate = date
                        realm.add(recentAddress, update: true)
                    } else {
                        let newRecentAddress = RecentAddressesRLM.createRecentAddress(blockchainType: blockchainType, address: address, date: date)
                        realm.add(newRecentAddress, update: false)
                    }
                }
            }
        }
    }
    
    func getRecentAddresses(for chain: UInt32?, netType: Int?, completion: @escaping (_ addresses: Results<RecentAddressesRLM>?, _ error: NSError?) -> ()) {
        getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                if chain != nil && netType != nil {
                    let addr = realm.objects(RecentAddressesRLM.self).filter("blockchain = \(chain!)").filter("blockchainNetType = \(netType!)").sorted(byKeyPath: "lastActionDate", ascending: false)
                    completion(addr, nil)
                } else {
                    let addr = realm.objects(RecentAddressesRLM.self).sorted(byKeyPath: "lastActionDate", ascending: false)
                    completion(addr, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
}

extension RealmMigrationManager {
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
    
    func migrateFrom13To14(with migration: Migration) {
        migration.enumerateObjects(ofType: UserWalletRLM.className()) { (_, newWallet) in
            newWallet?["chainType"] = NSNumber(value: 0)
        }
    }
    
    func migrateFrom14To15(with migration: Migration) {
        migration.enumerateObjects(ofType: UserWalletRLM.className()) { (_, newWallet) in
            newWallet?["isTherePendingTx"] = NSNumber(booleanLiteral: false)
        }
    }
    
    func migrateFrom15To16(with migration: Migration) {
//        migration.enumerateObjects(ofType: UserWalletRLM.className()) { (_, newWallet) in
//            newWallet?["networkID"] = NSNumber(value: 0)
//        }
    }
    
    func migrateFrom16To17(with migration: Migration) {
        migration.enumerateObjects(ofType: AddressRLM.className()) { (_, newAddress) in
            newAddress?["amountString"] = String()
        }
        migration.enumerateObjects(ofType: ETHWallet.className()) { (_, newETHWallet) in
            newETHWallet?["balance"] = String()
        }
        migration.enumerateObjects(ofType: HistoryRLM.className()) { (_, newHistoryRLM) in
            newHistoryRLM?["gasLimit"] = NSNumber(value: 0)
            newHistoryRLM?["gasPrice"] = NSNumber(value: 0)
            newHistoryRLM?["txOutAmountString"] = String()
        }
    }
    
    func migrateFrom17To18(with migration: Migration) {
        migration.enumerateObjects(ofType: StockExchangeRateRLM.className()) { (_, newRates) in
            newRates?["btc2usd"] = NSNumber(value: 0)
        }
    }
    
    func migrateFrom18To19(with migration: Migration) {
        migration.enumerateObjects(ofType: UserWalletRLM.className()) { (_, newWallet) in
            newWallet?["lastActivityTimestamp"] = NSNumber(value: 0)
        }
    }
    
    func migrateFrom19To20(with migration: Migration) {
        migration.enumerateObjects(ofType: RecentAddressesRLM.className()) { (_, newRecentAddress) in
            newRecentAddress?["lastActionDate"] = Date()
            newRecentAddress?["blockchain"] = NSNumber(value: 0)
            newRecentAddress?["blockchainNetType"] = NSNumber(value: 0)
        }
    }
}
