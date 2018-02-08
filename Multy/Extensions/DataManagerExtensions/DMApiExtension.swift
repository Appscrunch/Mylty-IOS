//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift
import Alamofire

extension DataManager {
    
    func getServerConfig(completion: @escaping(_ hardVersion: Int?,_ softVersion: Int?,_ error: Error?) -> ()) {
        apiManager.getServerConfig { (answerDict, err) in
            switch err {
            case nil:
                var apiVersion: NSString?
                var hardVersion: Int?
                var softVersion: Int?
                var serverTime: NSDate?
                
                if answerDict!["donate"] != nil {
                    if let donate = (answerDict!["donate"] as? NSDictionary), let btcAddress = donate["BTC"] as? String {
                        UserDefaults.standard.set(btcAddress, forKey: "BTCDonationAddress")
                        self.coreLibManager.donationAddress = btcAddress
                    }
                }
                
                
                if answerDict!["api"] != nil {
                    apiVersion = (answerDict!["api"] as? NSString)
                    UserDefaults.standard.set(apiVersion, forKey: "apiVersion")
                }
                
                if answerDict!["ios"] != nil {
                    let iosDict = answerDict!["ios"] as! NSDictionary
                    hardVersion = iosDict["hard"] as? Int
                    softVersion = iosDict["soft"] as? Int
                    
                    UserDefaults.standard.set(hardVersion, forKey: "hardVersion")
                    UserDefaults.standard.set(softVersion, forKey: "softVersion")
                }
                
                if answerDict!["servertime"] != nil {
                    let timestamp = answerDict!["servertime"]
                    serverTime = NSDate(timeIntervalSince1970: timestamp as! TimeInterval)
                    
                    UserDefaults.standard.set(serverTime, forKey: "serverTime")
                }
                
                if answerDict!["stockexchanges"] != nil {
                    let stocksDict = answerDict!["stockexchanges"] as! NSDictionary
                    let stocks = StockExchanges(dictWithStocks: stocksDict)
                    
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: stocks.stocks)
                    UserDefaults.standard.set(encodedData, forKey: "stocks")
                    
                    //for get dict from userDefaults
//                    let decoded  = UserDefaults.standard.object(forKey: UserDefaultsKeys.jobCategory.rawValue) as! Data
//                    let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! JobCategory
//                    print(decodedTeams.name)
                }
                completion(hardVersion, softVersion, nil)
                break
            default:
                //do it something
                completion(nil, nil, err)
                break
            }
        }
    }
    
    func auth(rootKey: String?, completion: @escaping (_ account: AccountRLM?,_ error: Error?) -> ()) {
        realmManager.getRealm { (realmOpt, error) in
            if let realm = realmOpt {
                let account = realm.object(ofType: AccountRLM.self, forPrimaryKey: 1)
                
                var params : Parameters = [ : ]
                
                if account != nil {
                    params["userID"] = account?.userID
                    params["deviceID"] = account?.deviceID
                    params["deviceType"] = account?.deviceType
                    params["pushToken"] = account?.pushToken
                    
                    self.apiManager.userID = account!.userID
                } else {
                    //MARK: names
                    var paramsDict = NSMutableDictionary()
                    if rootKey == nil {
                        let seedPhraseString = self.coreLibManager.createMnemonicPhraseArray().joined(separator: " ")
                        params["userID"] = self.getRootString(from: seedPhraseString).0
                        params["deviceID"] = "iOS \(UIDevice.current.name)"
                        params["deviceType"] = 1
                        params["pushToken"] = UUID().uuidString
                        
                        paramsDict = NSMutableDictionary(dictionary: params)
                        
                        paramsDict["seedPhrase"] = seedPhraseString
                        paramsDict["binaryData"] = self.coreLibManager.createSeedBinaryData(from: seedPhraseString)?.convertToHexString()
                        
                        self.apiManager.userID = params["userID"] as! String
                    } else {
                        params["userID"] = self.getRootString(from: rootKey!).0
                        params["deviceID"] = "iOS \(UIDevice.current.name)"//UUID().uuidString
                        params["deviceType"] = 1
                        params["pushToken"] = UUID().uuidString
                        
                        paramsDict = NSMutableDictionary(dictionary: params)
                        
                        let hexBinData = self.coreLibManager.createSeedBinaryData(from: rootKey!)?.convertToHexString()
                        paramsDict["binaryData"] = hexBinData
                        
                        print(paramsDict)
                        
                        self.apiManager.userID = params["userID"] as! String
                    }
                    
                    self.realmManager.updateAccount(paramsDict, completion: { (account, error) in
                        
                    })
                }
                
                self.apiManager.auth(with: params, completion: { (dict, error) in
                    if dict != nil {
                        self.realmManager.updateAccount(dict!, completion: { (account, error) in
                            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                            completion(account, error)
                        })
                    } else {
                        completion(nil, nil)
                    }
                })
            } else {
                print("Error fetching realm:\(#function)")
                completion(nil, nil)
            }
        }
    }
    
    func addWallet(params: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.addWallet(params) { (responceDict, error) in
            if error != nil {
                completion(NSDictionary(), nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func addAddress(params: Parameters, completion: @escaping (_ dict: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.addAddress(params) { (dict, error) in
            completion(dict, error)
        }
    }
    
    func getFeeRate(currencyID: UInt32, completion: @escaping (_ feeRateDict: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.getFeeRate(currencyID: currencyID) { (answer, error) in
            if error != nil || (answer!["code"] as! NSNumber).intValue != 200  {
                completion(nil, error)
            } else {
                completion(answer!["speeds"] as? NSDictionary, nil)
            }
        }
    }
    
    func getWalletsVerbose(completion: @escaping (_ walletsArr: NSArray?,_ error: Error?) -> ()) {
        apiManager.getWalletsVerbose() { (answer, err) in
            if err == nil {
                let dict = NSMutableDictionary()
                dict["topindexes"] = answer!["topindexes"]
                
                DataManager.shared.realmManager.updateAccount(dict, completion: { (_, _) in })
                
                if (answer?["code"] as? NSNumber)?.intValue == 200 {
                    print("getWalletsVerbose:\n \(answer ?? ["":""])")
                    if answer!["wallets"] is NSNull {
                        completion(NSArray(), nil)
                        
                        return
                    }
                    let walletsArrayFromApi = answer!["wallets"] as! NSArray
//                    let walletsArr = UserWalletRLM.initWithArray(walletsInfo: walletsArrayFromApi)
                    completion(walletsArrayFromApi, nil)
                } else {
                    //MARK: delete
                    if answer!["wallets"] is NSNull {
                        return
                    }
                    let walletsArrayFromApi = answer!["wallets"] as! NSArray
                    //                    let walletsArr = UserWalletRLM.initWithArray(walletsInfo: walletsArrayFromApi)
                    completion(walletsArrayFromApi, nil)
                }
            } else {
                completion(nil, err)
            }
        }
    }
    
    func getOneWalletVerbose(walletID: NSNumber, completion: @escaping (_ answer: UserWalletRLM?,_ error: Error?) -> ()) {
        apiManager.getOneWalletVerbose(walletID: walletID) { (dict, error) in
            if dict != nil && dict!["wallet"] != nil && !(dict!["wallet"] is NSNull) {
                let wallet = UserWalletRLM.initWithInfo(walletInfo: (dict!["wallet"] as! NSArray)[0] as! NSDictionary)
//                let addressesInfo = ((dict!["wallet"] as! NSArray)[0] as! NSDictionary)["addresses"]!
                
//                let addresses = AddressRLM.initWithArray(addressesInfo: addressesInfo as! NSArray)
                
                completion(wallet, nil)
            } else {
                completion(nil, error)
            }
            
            print("getOneWalletVerbose:\n\(dict)")
        }
    }
    
    func getWalletOutputs(currencyID: UInt32, address: String, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.getWalletOutputs(currencyID: currencyID, address: address) { (dict, error) in
            completion(dict, error)
        }
    }
    
    func getTransactionHistory(currencyID: NSNumber, walletID: NSNumber, completion: @escaping(_ historyArr: List<HistoryRLM>?,_ error: Error?) ->()) {
        apiManager.getTransactionHistory(currencyID: currencyID, walletID: walletID) { (answer, err) in
            switch err {
            case nil:
                if answer!["code"] as! Int == 200 {
                    if answer!["history"] is NSNull || (answer!["history"] as? NSArray)?.count == 0 {
                        //history empty
                        completion(nil, nil)
                        return
                    }
                    if answer!["history"] as? NSArray != nil {
                        let historyArr = answer!["history"] as! NSArray
                        let initializedArr = HistoryRLM.initWithArray(historyArr: historyArr)
                        
//                        self.realmManager.saveHistoryForWallet(historyArr: initializedArr, completion: { (histList) in
//                        })
                        
                        completion(initializedArr, nil)
                    }
                }
            default:
                completion(nil, err)
                break
            }
        }
    }
    
    func changeWalletName(currencyID: NSNumber, walletID: NSNumber, newName: String, completion: @escaping(_ answer: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.changeWalletName(currencyID: currencyID, walletID: walletID, newName: newName) { (answer, error) in
            if error == nil {
                if answer != nil {
                    
                }
                completion(answer!, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func sendHDTransaction(transactionParameters: Parameters, completion: @escaping (_ answer: NSDictionary?,_ error: Error?) -> ()) {
        apiManager.sendHDTransaction(transactionParameters: transactionParameters) { (answer, error) in
            completion(answer, error)
        }
    }
}
