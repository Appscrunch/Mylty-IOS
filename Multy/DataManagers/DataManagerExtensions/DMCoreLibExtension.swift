//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

extension DataManager {
//    func isDeviceJailbroken() -> Bool {
//        return coreLibManager.isDeviceJailbroken()
//    }
    
    func getMnenonicAllWords() -> Array<String> {
        return coreLibManager.mnemonicAllWords()
    }
    
    func getMnenonicArray() -> Array<String> {
        return coreLibManager.createMnemonicPhraseArray()
    }
    
    func startCoreTest() {
        coreLibManager.startTests()
    }
    
    func getRootString(from seedPhase: String) -> (String?, String?)  {
        var binaryData = coreLibManager.createSeedBinaryData(from: seedPhase)
        if binaryData != nil {
            return (coreLibManager.createExtendedKey(from: &binaryData!), nil)
        } else {
            return (nil, "Seed phrase is too short")
        }
        
    }
    
    
    
//    func createWallet(from seedPhrase: String, currencyID : UInt32, walletID : UInt32, addressID: UInt32) -> Dictionary<String, Any>? {
//        var binaryData = coreLibManager.createSeedBinaryData(from: seedPhrase)
//        
//        
//    }
    
    func createNewWallet(for binaryData: inout BinaryData, blockchain: BlockchainType, walletID: UInt32) -> Dictionary<String, Any>? {
        return coreLibManager.createWallet(from: &binaryData,blockchain: blockchain, walletID: walletID)
    }
    
    func isAddressValid(address: String, for wallet: UserWalletRLM) -> (isValid: Bool, message: String?) {
        return coreLibManager.isAddressValid(address: address, for: wallet)
    }
    
    func createAndSendDonationTransaction(transactionDTO: TransactionDTO, completion: @escaping(_ answer: String?,_ error: Error?) -> ()) {
        let core = DataManager.shared.coreLibManager
        let wallet = transactionDTO.choosenWallet!
        var binaryData = DataManager.shared.realmManager.account!.binaryDataString.createBinaryData()!
        
        
        let addressData = core.createAddress(blockchain: transactionDTO.blockchainType!,
                                             walletID: transactionDTO.choosenWallet!.walletID.uint32Value,
                                             addressID: UInt32(transactionDTO.choosenWallet!.addresses.count),
                                             binaryData: &binaryData)
        
        let trData = DataManager.shared.coreLibManager.createTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                                                         sendAddress: transactionDTO.sendAddress!,
                                                                         sendAmountString: transactionDTO.sendAmount!.fixedFraction(digits: 8),
                                                                         feePerByteAmount: "\(transactionDTO.transaction!.customFee!)",
                                                                         isDonationExists: false,
                                                                         donationAmount: "0",
                                                                         isPayCommission: false,
                                                                         wallet: transactionDTO.choosenWallet!,
                                                                         binaryData: &binaryData,
                                                                         inputs: transactionDTO.choosenWallet!.addresses)
        
        if trData.1 < 0 {
            completion(trData.0, NSError(domain: "", code: 400, userInfo: nil))
            
            return
        }

        let newAddressParams = [
            "walletindex"   : wallet.walletID.intValue,
            "address"       : addressData!["address"] as! String,
            "addressindex"  : wallet.addresses.count,
            "transaction"   : trData.0,
            "ishd"          : NSNumber(booleanLiteral: true)
            ] as [String : Any]
        
        let params = [
            "currencyid": wallet.chain,
            "payload"   : newAddressParams
            ] as [String : Any]
        
        DataManager.shared.sendHDTransaction(transactionParameters: params) { (dict, error) in
            print("---------\(dict)")
            
            //FIXME: create messages in bad cases
            if error != nil {
                print("sendHDTransaction Error: \(error)")
                completion(nil, nil)
                
                return
            }
            
            if dict!["code"] as! Int == 200 {
                completion("good", nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func createEtherTx(binaryData: inout BinaryData, wallet: UserWalletRLM, sendAddress: String, sendAmountString: String, gasPriceString: String, gasLimitString: String) {
        let blockchain = BlockchainType.create(wallet: wallet)
        let addressData = self.coreLibManager.createAddress(blockchain: blockchain, walletID: wallet.walletID.uint32Value, addressID: wallet.addressID.uint32Value, binaryData: &binaryData)
        
        let _ = self.coreLibManager.createEtherTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                                           sendAddress: sendAddress,
                                                           sendAmountString: sendAmountString,
                                                           nonce: wallet.ethWallet!.nonce.intValue,
                                                           balanceAmount: "\(wallet.availableAmount)",
                                                           ethereumChainID: UInt32(4), //RINKEBY
                                                           gasPrice: gasPriceString,
                                                           gasLimit: gasLimitString)
    }
    
    func privateKeyString(blockchain: BlockchainType, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> String {
        return coreLibManager.privateKeyString(blockchain: blockchain, walletID: walletID, addressID: addressID, binaryData: &binaryData)
    }
}
