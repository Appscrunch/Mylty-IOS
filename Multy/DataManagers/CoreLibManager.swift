//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

private typealias TestCoreLibManager = CoreLibManager
private typealias EthereumCoreLibManager = CoreLibManager

class CoreLibManager: NSObject {
    static let shared = CoreLibManager()
    
    func mnemonicAllWords() -> Array<String> {
        let mnemonicArrayPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        defer { mnemonicArrayPointer.deallocate(capacity: 1) }
        
        let mgd = mnemonic_get_dictionary(mnemonicArrayPointer)
        _ = errorString(from: mgd, mask: "mnemonic_get_dictionary")
        
        let mnemonicArrayString = String(cString: mnemonicArrayPointer.pointee!).trimmingCharacters(in: .whitespacesAndNewlines)
        
        return mnemonicArrayString.components(separatedBy: " ")
    }
    
    func createMnemonicPhraseArray() -> Array<String> {
        let mnemo = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        defer {
            free_string(mnemo.pointee)
            mnemo.deallocate(capacity: 1)
        }
        
        let entropySource = EntropySource.init(data: nil, fill_entropy: { (data, length, entropy) in
            guard entropy != nil else {
                return 0
            }
            
            let errorInt = SecRandomCopyBytes(kSecRandomDefault, length / 2, entropy!)
            
            if errorInt == errSecSuccess {
                return length / 2
            } else {
                return 0
            }
        })
        
        let mm = make_mnemonic(entropySource, mnemo)
        _ = errorString(from: mm, mask: "make_mnemonic")
        
        let phrase = String(cString: mnemo.pointee!)
        
        return phrase.components(separatedBy: " ")
    }
    
    func startTests() {
//        run_tests(1, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1))
    }
    
    func createSeedBinaryData(from phrase: String) -> BinaryData? {
        print("seed phrase: \(phrase)")
        let stringPointer = phrase.UTF8CStringPointer
        
        let binaryDataPointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        defer {
//            free_binarydata(binaryDataPointer.pointee)
            binaryDataPointer.deallocate(capacity: 1)
        }
        
        let ms = make_seed(stringPointer, nil, binaryDataPointer)
        
        if ms != nil {
            _ = errorString(from: ms!, mask: "make_seed")
            
            return nil
        }

        if binaryDataPointer.pointee != nil {
            return binaryDataPointer.pointee!.pointee
        } else {
            return nil
        }
    }
    
    func createExtendedKey(from binaryData: inout BinaryData) -> String {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let extendedKeyPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        defer {
            free_extended_key(masterKeyPointer.pointee)
            free_string(extendedKeyPointer.pointee)
            masterKeyPointer.deallocate(capacity: 1)
            extendedKeyPointer.deallocate(capacity: 1)
        }
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        _ = errorString(from: mmk, mask: "make_master_key")
        
        let mki = make_user_id_from_master_key(masterKeyPointer.pointee, extendedKeyPointer)
        _ = errorString(from: mki, mask: "make_key_id")
        
        let extendedKey = String(cString: extendedKeyPointer.pointee!)
        print("extended key: \(extendedKey)")
        
        return extendedKey
    }
    
    func createWallet(from binaryData: inout BinaryData, blockchain: BlockchainType, walletID: UInt32) -> Dictionary<String, Any>? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        _ = errorString(from: mmk, mask: "make_master_key")
        
        //HD Account
        let newAccountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //New address
        let newAddressPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let newAddressStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Private
        let addressPrivateKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let privateKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Public
        let addressPublicKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let publicKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //placed here since we have multiple returns
        defer {
            free_extended_key(masterKeyPointer.pointee)
            free_hd_account(newAccountPointer.pointee)
            
            free_account(newAddressPointer.pointee)
            free_string(newAddressStringPointer.pointee)
            
            free_key(addressPrivateKeyPointer.pointee)
            free_string(privateKeyStringPointer.pointee)
            
            free_key(addressPublicKeyPointer.pointee)
            free_string(publicKeyStringPointer.pointee)
            
            masterKeyPointer.deallocate(capacity: 1)
            newAccountPointer.deallocate(capacity: 1)
            
            newAddressPointer.deallocate(capacity: 1)
            newAddressStringPointer.deallocate(capacity: 1)
            
            addressPrivateKeyPointer.deallocate(capacity: 1)
            privateKeyStringPointer.deallocate(capacity: 1)
            
            addressPublicKeyPointer.deallocate(capacity: 1)
            publicKeyStringPointer.deallocate(capacity: 1)
        }

        let mHDa = make_hd_account(masterKeyPointer.pointee, blockchain, walletID, newAccountPointer)
        if mHDa != nil {
            _ = errorString(from: mHDa, mask: "make_hd_account")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_EXTERNAL, 0, newAddressPointer)
        if mHDla != nil {
            _ = errorString(from: mHDla!, mask: "make_hd_leaf_account")
            
            return nil
        }
        
        //Create wallet
        var walletDict = Dictionary<String, Any>()
        walletDict["currency"] = blockchain.blockchain.rawValue
        walletDict["walletID"] = walletID
        walletDict["addressID"] = UInt32(0)
        
        let agas = account_get_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String? = nil
        if agas != nil {
            _ = errorString(from: agas, mask: "account_get_address_string")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString!)")
            
            walletDict["address"] = addressString!
        }
        
        let gakPRIV = account_get_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        _ = errorString(from: gakPRIV, mask: "account_get_key:KEY_TYPE_PRIVATE")
        let gakPUBL = account_get_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        _ = errorString(from: gakPUBL, mask: "account_get_key:KEY_TYPE_PUBLIC")
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        _ = errorString(from: ktsPRIV, mask: "key_to_string:KEY_TYPE_PRIVATE")
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        _ = errorString(from: ktsPUBL, mask: "key_to_string:KEY_TYPE_PUBLIC")
        
        var privateKeyString : String?
        var publicKeyString : String?
        
        if ktsPRIV != nil {
            return nil
        } else {
            privateKeyString = String(cString: privateKeyStringPointer.pointee!)
            walletDict["privateKey"] = privateKeyString
        }
        
        if ktsPUBL != nil {
            return nil
        } else {
            publicKeyString = String(cString: publicKeyStringPointer.pointee!)
            walletDict["publicKey"] = publicKeyString
        }
        
        return walletDict
    }
    
    func createPrivateKey(blockchain: BlockchainType, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> UnsafeMutablePointer<OpaquePointer?>? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        _ = errorString(from: mmk, mask: "make_master_key")
        
        //HD Account
        let newAccountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //New address
        let newAddressPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //Private
        let addressPrivateKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)

        //placed here since we have multiple return
        defer {
            free_extended_key(masterKeyPointer.pointee)
            free_hd_account(newAccountPointer.pointee)
            free_account(newAddressPointer.pointee)
            
            masterKeyPointer.deallocate(capacity: 1)
            newAccountPointer.deallocate(capacity: 1)
            newAddressPointer.deallocate(capacity: 1)
        }
        
        let mHDa = make_hd_account(masterKeyPointer.pointee, blockchain, walletID, newAccountPointer)
        if mHDa != nil {
            _ = errorString(from: mHDa!, mask: "mHDa")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_EXTERNAL, addressID, newAddressPointer)
        if mHDla != nil {
            _ = errorString(from: mHDla!, mask: "mHDla")
            
            return nil
        }
        
        let gakPRIV = account_get_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        if gakPRIV != nil {
            _ = errorString(from: gakPRIV!, mask: "gakPRIV")
            
            return nil
        } else {
            
            return addressPrivateKeyPointer
        }
    }
    
    func privateKeyString(blockchain: BlockchainType, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> String {
        let privateKeyPointer = createPrivateKey(blockchain: blockchain, walletID: walletID, addressID: addressID, binaryData: &binaryData)
        
        let privateKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        let ktsPRIV = key_to_string(privateKeyPointer!.pointee, privateKeyStringPointer)
        _ = errorString(from: ktsPRIV, mask: "key_to_string:KEY_TYPE_PRIVATE")
        
        let privateKeyString = String(cString: privateKeyStringPointer.pointee!)
        
        return privateKeyString
    }
    
    func createAddress(blockchain: BlockchainType, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> Dictionary<String, Any>? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        _ = errorString(from: mmk, mask: "make_master_key")
        
        //HD Account
        let newAccountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //New address
        let newAddressPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let newAddressStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Private
        let addressPrivateKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let privateKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Public
        let addressPublicKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let publicKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //placed here since we have multiple return
        defer {
            free_extended_key(masterKeyPointer.pointee)
            free_hd_account(newAccountPointer.pointee)
            
            //will be free later
//            free_account(newAddressPointer.pointee)
            free_string(newAddressStringPointer.pointee)
            
            free_key(addressPrivateKeyPointer.pointee)
            free_string(privateKeyStringPointer.pointee)
            
            free_key(addressPublicKeyPointer.pointee)
            free_string(publicKeyStringPointer.pointee)
            
            masterKeyPointer.deallocate(capacity: 1)
            newAccountPointer.deallocate(capacity: 1)
//            newAddressPointer.deallocate(capacity: 1)
            newAddressStringPointer.deallocate(capacity: 1)
            addressPrivateKeyPointer.deallocate(capacity: 1)
            privateKeyStringPointer.deallocate(capacity: 1)
            addressPublicKeyPointer.deallocate(capacity: 1)
            publicKeyStringPointer.deallocate(capacity: 1)
        }
        
        let mHDa = make_hd_account(masterKeyPointer.pointee, blockchain, walletID, newAccountPointer)
        if mHDa != nil {
            _ = errorString(from: mHDa!, mask: "make_hd_account")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_EXTERNAL, addressID, newAddressPointer)
        if mHDla != nil {
            _ = errorString(from: mHDa!, mask: "make_hd_leaf_account")
            
            return nil
        }
        
        //Create wallet
        var addressDict = Dictionary<String, Any>()
        addressDict["currencyID"] = blockchain.blockchain.rawValue
        addressDict["walletIndex"] = walletID
        addressDict["addressIndex"] = addressID
        addressDict["addressPointer"] = newAddressPointer
        
        let agas = account_get_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String?
        if agas != nil {
            _ = errorString(from: agas, mask: "account_get_address_string")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString!)")
            
            addressDict["address"] = addressString!
        }
        
        let gakPRIV = account_get_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        _ = errorString(from: gakPRIV, mask: "account_get_key:KEY_TYPE_PRIVATE")
        let gakPUBL = account_get_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        _ = errorString(from: gakPUBL, mask: "account_get_key:KEY_TYPE_PUBLIC")
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        _ = errorString(from: ktsPRIV, mask: "key_to_string:KEY_TYPE_PRIVATE")
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        _ = errorString(from: ktsPUBL, mask: "key_to_string:KEY_TYPE_PUBLIC")
        
        var privateKeyString : String?
        var publicKeyString : String?
        
        if ktsPRIV != nil {
            return nil
        } else {
            privateKeyString = String(cString: privateKeyStringPointer.pointee!)
            addressDict["privateKey"] = privateKeyString!
        }
        
        if ktsPUBL != nil {
            return nil
        } else {
            publicKeyString = String(cString: publicKeyStringPointer.pointee!)
            addressDict["publicKey"] = publicKeyString!
            
        }
        
        return addressDict
    }
    
    func createTransaction(addressPointer: UnsafeMutablePointer<OpaquePointer?>,
                           sendAddress: String,
                           sendAmountString: String,
                           feePerByteAmount: String,
                           isDonationExists: Bool,
                           donationAmount: String,
                           isPayCommission: Bool,
                           wallet: UserWalletRLM,
                           binaryData: inout BinaryData,
                           inputs: List<AddressRLM>) -> (String, Double) {
        let blockchain = BlockchainType.create(wallet: wallet)
        let inputs = DataManager.shared.realmManager.spendableOutput(addresses: inputs)
        let inputSum = DataManager.shared.spendableOutputSum(outputs: inputs)
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        defer {
            free_transaction(transactionPointer.pointee)
            transactionPointer.deallocate(capacity: 1)
        }
        
        let mt = make_transaction(addressPointer.pointee, transactionPointer)
        
        if mt != nil {
            return (errorString(from: mt, mask: "make_transaction")!, -1)
        }
        
        //fee
        let fee = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        defer { fee.deallocate(capacity: 1) }
        
        let tgf = transaction_get_fee(transactionPointer.pointee, fee)
        if tgf != nil {
            return (errorString(from: tgf, mask: "transaction_get_fee")!, -1)
        }
        
        let maxFee = UInt64(feePerByteAmount)!
        //let maxFeeString = String(maxFee + (maxFee / 5) + 1)// 20% error
        
        //Amount
        setAmountValue(key: "amount_per_byte", value: feePerByteAmount, pointer: fee.pointee!)
        //setAmountValue(key: "max_amount_per_byte", value: maxFeeString, pointer: fee.pointee!) // optional

        //spendable info
        for input in inputs {
            let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            defer {
                transactionSource.deallocate(capacity: 1)
            }
            
            let tas = transaction_add_source(transactionPointer.pointee, transactionSource)
            if tas != nil {
                return (errorString(from: tas, mask: "transaction_add_source")!, -1)
            }
            
            setAmountValue(key: "amount",
                           value: String(describing: input.transactionOutAmount),
                           pointer: transactionSource.pointee!)
            setBinaryDataValue(key: "prev_tx_hash",
                               value: input.transactionID,
                               pointer: transactionSource.pointee!)
            setIntValue(key: "prev_tx_out_index",
                        value: input.transactionOutID.uint32Value,
                        pointer: transactionSource.pointee!)
            setBinaryDataValue(key: "prev_tx_out_script_pubkey",
                               value: input.transactionOutScript,
                               pointer: transactionSource.pointee!)
            
            let privateKey = createPrivateKey(blockchain: blockchain,
                                              walletID: wallet.walletID.uint32Value,
                                              addressID: input.addressID.uint32Value,
                                              binaryData: &binaryData)
            //FIXME: check nil pointer
            setPrivateKeyValue(key: "private_key", value: privateKey!.pointee!, pointer: transactionSource.pointee!)
            
            privateKey!.deallocate(capacity: 1)
        }
        
        var sendSum = UInt64(0)
        var changeSum = UInt64(0)
        let sendSumInSatoshi = convertBTCStringToSatoshi(sum: sendAmountString)
        let donationSumInSatoshi = convertBTCStringToSatoshi(sum: donationAmount)

        if sendSumInSatoshi < donationSumInSatoshi {
            return ("Sending amount (\(sendAmountString) BTC) must be greater then donation amount (\(donationAmount) BTC)", -2)
        }
        
        sendSum = sendSumInSatoshi
        
        //address
        let transactionDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tad = transaction_add_destination(transactionPointer.pointee, transactionDestination)
        if tad != nil {
            return (errorString(from: tad, mask: "transaction_add_destination")!, -1)
        }
        
        setStringValue(key: "address", value: sendAddress, pointer: transactionDestination.pointee!)

        //donation
        if isDonationExists {
            let donationDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            defer { donationDestination.deallocate(capacity: 1) }
            
            let tad = transaction_add_destination(transactionPointer.pointee, donationDestination)
            if tad != nil {
                return (errorString(from: tad, mask: "transaction_add_destination")!, -1)
            }
            
            let currentChainDonationAddress = DataManager.shared.getBTCDonationAddress(netType: wallet.chainType.uint32Value)
            
            setStringValue(key: "address", value: currentChainDonationAddress, pointer: donationDestination.pointee!)
            setAmountValue(key: "amount", value: String(convertBTCStringToSatoshi(sum: donationAmount)), pointer: donationDestination.pointee!)
        }
        
        //change
        //MARK: UInt32(wallet.addresses.count)
        let dict = createAddress(blockchain: blockchain,
                                 walletID: wallet.walletID.uint32Value,
                                 addressID: UInt32(wallet.addresses.count),
                                 binaryData: &binaryData)
        
        //if we send MAX than we mark "is_change" for destination
        if sendSumInSatoshi == inputSum {
            setIntValue(key: "is_change", value: UInt32(1), pointer: transactionDestination.pointee!)
        } else {
            if !isPayCommission {
                sendSum -= donationSumInSatoshi
            }
            
            setAmountValue(key: "amount", value: String(sendSum), pointer: transactionDestination.pointee!)
            
            let changeDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            defer { changeDestination.deallocate(capacity: 1) }
            
            let tad = transaction_add_destination(transactionPointer.pointee, changeDestination)
            if tad != nil {
                return (errorString(from: tad, mask: "transaction_add_destination")!, -1)
            }
            
            setIntValue(key: "is_change", value: UInt32(1), pointer: changeDestination.pointee!)
            setStringValue(key: "address", value: dict!["address"] as! String, pointer: changeDestination.pointee!)
            //        setAmountValue(key: "amount", value: String(changeSum), pointer: changeDestination.pointee!)
        }
        
        //final
        let serializedTransaction = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        
        let tu = transaction_update(transactionPointer.pointee)
        if tu != nil {
            return (errorString(from: tu, mask: "transaction_update")!, -1)
        }
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //modify sums after transaction update
        
        let totalSumPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)

        let tgtf = transaction_get_total_fee(transactionPointer.pointee, totalSumPointer)
        defer {
            free_big_int(totalSumPointer.pointee)
            totalSumPointer.deallocate(capacity: 1)
        }
        if tgtf != nil {
            return (errorString(from: tgtf, mask: "transaction_get_total_fee")!, -1)
        }
        
        
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        defer {
            free_string(amountStringPointer.pointee)
        }
        
        let bits = big_int_to_string(totalSumPointer.pointee, amountStringPointer)
        if bits != nil {
            return (errorString(from: bits, mask: "big_int_to_string")!, -1)
        }
        
        let amountString = String(cString: amountStringPointer.pointee!)
        let feeInSatoshiAmount = UInt64(amountString)!
        let feeInBTCAmount = feeInSatoshiAmount.btcValue
        
        //checking sums
        
        if isPayCommission {
            sendSum = sendSumInSatoshi
            if inputSum < sendSum + donationSumInSatoshi + feeInSatoshiAmount {
                return ("Wallet amount (\(convertSatoshiToBTCString(sum: inputSum))) must be greater the send amount (\(convertSatoshiToBTCString(sum: sendSum))) plus fee amount (\(convertSatoshiToBTCString(sum: feeInSatoshiAmount))) plus donation amount (\(donationAmount) BTC)", -2)
            } else {
                //reamins just for checking all sums - automatically calculated in core library
                changeSum = inputSum - (sendSum + donationSumInSatoshi + feeInSatoshiAmount)
            }
        } else {
            if sendSumInSatoshi < donationSumInSatoshi + feeInSatoshiAmount {
                return ("Sending amount (\(sendAmountString) BTC) must be greater then fee amount (\(convertSatoshiToBTCString(sum: feeInSatoshiAmount))) plus donation (\(donationAmount) BTC)", -2)
            } else {
                if sendSumInSatoshi != inputSum {
                    sendSum = sendSumInSatoshi - (donationSumInSatoshi + feeInSatoshiAmount)
                    //update value for sending sum
                    setAmountValue(key: "amount", value: String(sendSum), pointer: transactionDestination.pointee!)
                    
                    //reamins just for checking all sums - automatically calculated in core library
                    changeSum = inputSum - sendSumInSatoshi
                }
            }
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let tSer = transaction_serialize(transactionPointer.pointee, serializedTransaction)
        defer {
            free_binarydata(serializedTransaction.pointee)
            serializedTransaction.deallocate(capacity: 1)
        }
        if tSer != nil {
            return (errorString(from: tSer, mask: "transaction_serialize")!, -1)
        }
        
        let data = serializedTransaction.pointee!.pointee.convertToData()
        let str = data.hexEncodedString()
        
        print("end transaction: \(str)")
        
        return (str, feeInBTCAmount)
    }
    
    func setAmountValue(key: String, value: String, pointer: OpaquePointer) {
        let amountKey = key.UTF8CStringPointer
        let amountValue = value.UTF8CStringPointer
        
        let amountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let mbi = make_big_int(amountValue, amountPointer)
        defer {
            free_big_int(amountPointer.pointee)
            amountPointer.deallocate(capacity: 1)
        }
        _ = errorString(from: mbi, mask: "make_big_int")
        
        let psav = properties_set_big_int_value(pointer, amountKey, amountPointer.pointee)
        _ = errorString(from: psav, mask: "properties_set_big_int_value")
    }
    
    func setBinaryDataValue(key: String, value: String, pointer: OpaquePointer) {
        let binaryKey = key.UTF8CStringPointer
        let dataValue = value.UTF8CStringPointer
        
        let binDataPointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        let mbfh = make_binary_data_from_hex(dataValue, binDataPointer)
        defer {
            free_binarydata(binDataPointer.pointee)
            binDataPointer.deallocate(capacity: 1)
        }
        _ = errorString(from: mbfh, mask: "make_binary_data_from_hex")
        
        let psbdv = properties_set_binary_data_value(pointer, binaryKey, binDataPointer.pointee)
        _ = errorString(from: psbdv, mask: "properties_set_binary_data_value")
    }
    
    func setIntValue(key: String, value: UInt32, pointer: OpaquePointer) {
        let intKey = key.UTF8CStringPointer
        let intValue = Int32(value)

        let psi = properties_set_int32_value(pointer, intKey, intValue)
        _ = errorString(from: psi, mask: "setIntValue")
    }
    
    func setStringValue(key: String, value: String, pointer: OpaquePointer) {
        let stringKey = key.UTF8CStringPointer
        let stringValue = value.UTF8CStringPointer
        
        let pstv = properties_set_string_value(pointer, stringKey, stringValue)
        _ = errorString(from: pstv, mask: "setStringValue")
    }
    
    func setPrivateKeyValue(key: String, value: OpaquePointer, pointer: OpaquePointer) {
        let stringKey = key.UTF8CStringPointer
        
        let pspkv = properties_set_private_key_value(pointer, stringKey, value)
        _ = errorString(from: pspkv, mask: "setPrivateKeyValue")
    }
    
    func errorString(from opaquePointer: OpaquePointer?, mask: String) -> String? {
        guard let opaquePointer = opaquePointer else {
            return nil
        }
        
        defer { free_error(opaquePointer) }
        
        let pointer = UnsafeMutablePointer<CustomError>(opaquePointer)
        let errorString = String(cString: pointer.pointee.message)
        
        print("\(mask): \(errorString))")
        
        return errorString
    }
    
    func isAddressValid(address: String, for wallet: UserWalletRLM) -> (Bool, String?) {
        let addressUTF8 = address.UTF8CStringPointer
        //FIXME: Blockchain values
        let blockchainType = BlockchainType.create(wallet: wallet)
        let error = validate_address(blockchainType, addressUTF8)
        
        let errorString = self.errorString(from: error!, mask: "isAddressValid")
        
        return (errorString == nil, errorString)
    }
    
    func getCoreLibVersion() -> String {
        let versionFromCoreLib = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        defer {
            versionFromCoreLib.deallocate(capacity: 1)
        }
        
        let error = make_version_string(versionFromCoreLib)
        
        if error == nil {
            return String(cString: versionFromCoreLib.pointee!)
        } else {
            _ = errorString(from: error, mask: "coreLibVersion")
            
            return ""
        }
    }
}

////////////////////////////////////
extension TestCoreLibManager {
    func startSwiftTest() {
        let mnemo = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        let entropySource = EntropySource.init(data: nil, fill_entropy: { (data, length, entropy) in
            guard entropy != nil else {
                return 0
            }
            
            let errorInt = SecRandomCopyBytes(kSecRandomDefault, length / 2, entropy!)
            
            if errorInt == errSecSuccess {
                return length / 2
            } else {
                return 0
            }
        })
        
        let mm = make_mnemonic(entropySource, mnemo)
        
        //MAKE: check nil
        print("make_mnemonic: \(mm)")
        
        let phrase = String(cString: mnemo.pointee!)
        
        print("seed phrase: \(phrase)")
        
        let stringPointer = phrase.UTF8CStringPointer
        let binaryDataPointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        
        let ms = make_seed(stringPointer, nil, binaryDataPointer)
        
        print("make_seed: \(ms)")
        
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let extendedKeyPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        var mmk = make_master_key(binaryDataPointer.pointee, masterKeyPointer)
        print("make_master_key: \(String(describing: mmk))")
        
        var mki = make_user_id_from_master_key(masterKeyPointer.pointee, extendedKeyPointer)
        print("make_key_id: \(String(describing: mki))")
        
        let extendedKey = String(cString: extendedKeyPointer.pointee!)
        print("extended key: \(extendedKey)")
        
        //HD Account
        
        let newAccountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //New address
        let newAddressPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let newAddressStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Private
        let addressPrivateKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let privateKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        //Public
        let addressPublicKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let publicKeyStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        let blockchain = BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN.rawValue, netType: BITCOIN_NET_TYPE_MAINNET.rawValue)
        let mHDa = make_hd_account(masterKeyPointer.pointee, blockchain, UInt32(0), newAccountPointer)
        print("make_hd_account: \(mHDa)")
        
        if mHDa != nil {
            _ = errorString(from: mHDa!, mask: "make_hd_account")
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee!, ADDRESS_EXTERNAL, UInt32(0), newAddressPointer)
        //        make_hd_leaf_account(OpaquePointer!, AddressType, UInt32, UnsafeMutablePointer<OpaquePointer?>!)
        if mHDla != nil {
            _ = errorString(from: mHDla!, mask: "make_hd_leaf_account")
        }
        
        //Create wallet
        
        let gaas = account_get_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String? = nil
        if gaas != nil {
            _ = errorString(from: gaas!, mask: "account_get_address_string")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString!)")
        }
        
        let gakPRIV = account_get_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        let gakPUBL = account_get_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        
        print("\(gakPRIV) - \(gakPUBL) - \(ktsPRIV) - \(ktsPUBL)")
        
        
        let currencyPointer = UnsafeMutablePointer<BlockchainType>.allocate(capacity: 1)
        let gac = account_get_blockchain_type(newAddressPointer.pointee, currencyPointer)
        print("gac: \(gac)")
        
        let currency : BlockchainType = currencyPointer.pointee
        print("another currency: \(currency)")
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        
        let mt = make_transaction(newAddressPointer.pointee, transactionPointer)
        defer { free_transaction(transactionPointer.pointee) }
        if mt != nil {
            _ = errorString(from: mt!, mask: "make_hd_account")
        }
        
        print("END")
        
        defer {
            mnemo.deallocate(capacity: 1)
            //            stringPointer.deallocate(capacity: 1)
            binaryDataPointer.deallocate(capacity: 1)
            masterKeyPointer.deallocate(capacity: 1)
            extendedKeyPointer.deallocate(capacity: 1)
            newAccountPointer.deallocate(capacity: 1)
            newAddressPointer.deallocate(capacity: 1)
            newAddressStringPointer.deallocate(capacity: 1)
            
            //Private
            addressPrivateKeyPointer.deallocate(capacity: 1)
            privateKeyStringPointer.deallocate(capacity: 1)
            
            //Public
            addressPublicKeyPointer.deallocate(capacity: 1)
            publicKeyStringPointer.deallocate(capacity: 1)
            
            currencyPointer.deallocate(capacity: 1)
            
            transactionPointer.deallocate(capacity: 1)
            transactionSource.deallocate(capacity: 1)
        }
        
        //creating tx
        //Check if exist wallet by walletID
        DataManager.shared.realmManager.getWallet(walletID: 1) { (wallet) in
            let addressData = self.createAddress(blockchain:    blockchain,
                                                 walletID:      wallet!.walletID.uint32Value,
                                                 addressID:     UInt32(wallet!.addresses.count),
                                                 binaryData:    &binaryDataPointer.pointee!.pointee)
            
            let data = self.createTransaction(addressPointer: addressData!["addressPointer"] as! UnsafeMutablePointer<OpaquePointer?>,
                                              sendAddress: Constants.DataManager.btcTestnetDonationAddress,
                                              sendAmountString: "0,001",
                                              feePerByteAmount: "2",
                                              isDonationExists: false,
                                              donationAmount: "0",
                                              isPayCommission: true,
                                              wallet: wallet!,
                                              binaryData: &binaryDataPointer.pointee!.pointee,
                                              inputs: wallet!.addresses)
            print("tx: \(data.0)")
        }
    }
    
    func testUserPreferences() {
        //user prefs test
        let userPrefs = UserPreferences.shared
        
        userPrefs.getAndDecryptPin { (string, error) in
            print("pin string: \(String(describing: string)) - error: \(String(describing: error))")
        }
        
        userPrefs.getAndDecryptBiometric { (isOn, error) in
            print("biometric: \(String(describing: isOn)) - error: \(String(describing: error))")
        }
        
        userPrefs.getAndDecryptCipheredMode { (isOn, error) in
            print("ciphered mode: \(String(describing: isOn)) - error: \(String(describing: error))")
        }
        
        userPrefs.getAndDecryptDatabasePassword { (dataPass, error) in
            print("ciphered mode: \(String(describing: dataPass)) - error: \(String(describing: error))")
        }
        
        print("\n\n---===The end of the user's prefs test===---\n\n")
    }
}


//////////////////////////
extension EthereumCoreLibManager {
    func createEtherTransaction(addressPointer: UnsafeMutablePointer<OpaquePointer?>,
                                sendAddress: String,
                                sendAmountString: String,
                                nonce: Int,
                                balanceAmount: String,
                                ethereumChainID: UInt32,
                                gasPrice: String,
                                gasLimit: String) -> String {
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mt = make_transaction(addressPointer.pointee, transactionPointer)
        defer { free_transaction(transactionPointer.pointee) }
        if mt != nil {
            _ = errorString(from: mt!, mask: "make_transaction")
        }
        
        //properties
        let accountProperties = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgp = transaction_get_properties(transactionPointer.pointee!, accountProperties)
        
        setAmountValue(key: "nonce", value: "\(nonce)", pointer: accountProperties.pointee!)
        setIntValue(key: "chain_id", value: ethereumChainID, pointer: accountProperties.pointee!)
        
        //balance
        let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tas = transaction_add_source(transactionPointer.pointee, transactionSource)
        setAmountValue(key: "amount", value: balanceAmount, pointer: transactionSource.pointee!)
        
        //destination
        let transactionDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tas2 = transaction_add_destination(transactionPointer.pointee, transactionDestination)
        setAmountValue(key: "amount", value: sendAmountString, pointer: transactionDestination.pointee!) //10^15 wei
        setBinaryDataValue(key: "address", value: sendAddress, pointer: transactionDestination.pointee!)
        
        //fee
        let feeProperties = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgpfp = transaction_get_fee(transactionPointer.pointee!, feeProperties)
        setAmountValue(key: "gas_price", value: gasPrice, pointer: feeProperties.pointee!)
        setAmountValue(key: "gas_limit", value: gasLimit, pointer: feeProperties.pointee!)
        
        //final
        let serializedTransaction = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        let tSer = transaction_serialize(transactionPointer.pointee, serializedTransaction)
        
        if tSer != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tSer)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tSer: \(errrString))")
            
            defer { pointer?.deallocate(capacity: 1) }
            
            return errrString
        }
        
        let data = serializedTransaction.pointee!.pointee.convertToData()
        let str = data.hexEncodedString()
        
        print("end transaction: \(str)")
        
        return str
    }
}
