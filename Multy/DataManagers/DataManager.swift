//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class DataManager: NSObject {
    static let shared = DataManager()
    
    let apiManager = ApiManager.shared
    let realmManager = RealmManager.shared
    let socketManager = Socket.shared
    let coreLibManager = CoreLibManager.shared
    
    var seedWordsArray = [String]()
    
    var donationCode = 0
    var btcMainNetDonationAddress = String()
    
    var currencyExchange = CurrencyExchange()
    
    override init() {
        super.init()
        
        seedWordsArray = coreLibManager.mnemonicAllWords()
    }
    
    func getBTCDonationAddress(netType: UInt32) -> String {
        return netType == 0 ? btcMainNetDonationAddress : Constants.DataManager.btcTestnetDonationAddress
    }
    
    func getBTCDonationAddressesFromUserDerfaults() -> Dictionary<Int, String> {
        let donationData  = UserDefaults.standard.object(forKey: Constants.UserDefaults.btcDonationAddressesKey) as! Data
        let decodedDonationAddresses = NSKeyedUnarchiver.unarchiveObject(with: donationData) as! Dictionary<Int, String>
        
        return decodedDonationAddresses
    }
    
    func isWordCorrect(word: String) -> Bool {
        if seedWordsArray.count > 0 {
            return seedWordsArray.contains(word)
        } else {
            return true
        }
    }
    
    func findPrefixes(prefix: String) -> [String] {
        return seedWordsArray.filter{ $0.hasPrefix(prefix) }
    }
    
    func checkIsFirstLaunch() -> Bool {
        if let isFirst = UserDefaults.standard.value(forKey: "isFirstLaunch") {
            return isFirst as! Bool
        } else {
//            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            return true
        }
    }
    
    func checkTermsOfService() -> Bool {
        if let isTerms = UserDefaults.standard.value(forKey: "isTermsAccept") {
            return isTerms as! Bool
        } else {
            //            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            return true
        }
    }
    
    func makeExchangeFor(blockchainType: BlockchainType) -> Double {
        switch blockchainType.blockchain {
        case BLOCKCHAIN_BITCOIN:
            return self.currencyExchange.btcToUSD
        case BLOCKCHAIN_ETHEREUM:
            return self.currencyExchange.ethToUSD
        default: return 1.0
        }
    }
    
    func generateWalletPrimaryKey(currencyID: UInt32, networkID: UInt32, walletID: UInt32) -> String {
        let currencyString = String(currencyID).sha3(.sha256)
        let walletString = String(walletID).sha3(.sha256)
        let networkString = String(networkID).sha3(.sha256)
        
        return ("\(currencyString)" + "\(walletString) +\(networkString)").sha3(.sha256)
    }
}
