//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class CoreLibManager: NSObject {
    static let shared = CoreLibManager()
    var donationAddress = UserDefaults.standard.string(forKey: "BTCDonationAddress") != nil ? UserDefaults.standard.string(forKey: "BTCDonationAddress")! : ""
    
    func testTransaction(from binaryData: inout BinaryData, wallet: UserWalletRLM) {
        
//        let inData = Date()
//        let dict = createAddress(currencyID: wallet.chain.uint32Value, walletID: wallet.walletID.uint32Value, addressID: 0, binaryData: &binaryData)
//        let str = createTransaction(addressPointer: dict!["addressPointer"] as! OpaquePointer,
//                                    sendAddress: "mkYY2jFnnqrqbQFNnp9eJ5NSV2ggyY1yET",
//                                    sendAmountString: "60000",
//                                    feeAmountString: "10000",
//                                    isDonationExists: true,
//                                    donationAmount: "10",
//                                    wallet: wallet,
//                                    binaryData: &binaryData)
//        let outData = Date()
//        
//        print("str: \(str)\n\(outData.timeIntervalSince(inData))")
    }
    
    func createMnemonicPhraseArray() -> Array<String> {
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
        print(mm ?? "-11")
        
        let phrase = String(cString: mnemo.pointee!)
        
        return phrase.components(separatedBy: " ")
    }
    
    func startTests() {
//        run_tests(1, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 1))
    }
    
    func createSeedBinaryData(from phrase: String) -> BinaryData? {
        //MAKE: free data
        //use defer function!!!
        
        print("seed phrase: \(phrase)")
        let stringPointer = phrase.UTF8CStringPointer
        let binaryDataPointer = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        
        let ms = make_seed(stringPointer, nil, binaryDataPointer)
        
        if ms != nil {
            print("ms: \(String(describing: ms))")
            let _ = returnErrorString(opaquePointer: ms!, mask: "make_seed")
            
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
        
        var mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        print("mmk: \(String(describing: mmk))")
        
        var mki = make_key_id(masterKeyPointer.pointee, extendedKeyPointer)
        print("mki: \(String(describing: mki))")
        
        let extendedKey = String(cString: extendedKeyPointer.pointee!)
        print("extended key: \(extendedKey)")
        
        //free data
//        binaryDataPointer.deallocate(capacity: 1)
//        masterKeyPointer.deallocate(capacity: 1)
//        extendedKeyPointer.deallocate(capacity: 1)
        mmk = nil
        mki = nil
//        binaryData = nil
        
        return extendedKey
    }
    
    func createWallet(from binaryData: inout BinaryData, currencyID: UInt32, walletID: UInt32) -> Dictionary<String, Any>? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        print("mmk: \(String(describing: mmk))")
        
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

        let mHDa = make_hd_account(masterKeyPointer.pointee, Currency.init(currencyID), walletID, newAccountPointer)
        if mHDa != nil {
            print("mHDa: \(String(describing: mHDa))")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_INTERNAL, 0, newAddressPointer)
        if mHDa != nil {
            print("mHDla: \(String(describing: mHDla))")
            
            return nil
        }
        
        //Create wallet
        var walletDict = Dictionary<String, Any>()
        walletDict["currency"] = currencyID
        walletDict["walletID"] = walletID
        walletDict["addressID"] = UInt32(0)
        
        let gaas = get_account_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String? = nil
        if gaas != nil {
            print("Cannot get address string: \(String(describing: gaas))")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString)")
            
            walletDict["address"] = addressString!
        }
        
        let gakPRIV = get_account_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        let gakPUBL = get_account_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        
        print("\(gakPRIV) - \(gakPUBL) - \(ktsPRIV) - \(ktsPUBL)")
        
        var privateKeyString : String? = nil
        var publicKeyString : String? = nil
        
        if ktsPRIV != nil {
            print("Cannot get private string: \(String(describing: gaas))")
        } else {
            privateKeyString = String(cString: privateKeyStringPointer.pointee!)
            walletDict["privateKey"] = privateKeyString
        }
        
        if ktsPUBL != nil {
            print("Cannot get public string: \(String(describing: gaas))")
        } else {
            publicKeyString = String(cString: publicKeyStringPointer.pointee!)
            walletDict["publicKey"] = publicKeyString
        }
        
        return walletDict
    }
    
    func createPrivateKey(currencyID: UInt32, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> OpaquePointer? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        print("mmk: \(String(describing: mmk))")
        
        //HD Account
        let newAccountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //New address
        let newAddressPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        //Private
        let addressPrivateKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)

        
        let mHDa = make_hd_account(masterKeyPointer.pointee, Currency.init(currencyID), walletID, newAccountPointer)
        if mHDa != nil {
            let _ = returnErrorString(opaquePointer: mHDa!, mask: "mHDa")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_INTERNAL, addressID, newAddressPointer)
        if mHDla != nil {
            let _ = returnErrorString(opaquePointer: mHDla!, mask: "mHDla")
            
            return nil
        }
        
        let gakPRIV = get_account_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        if gakPRIV != nil {
            let _ = returnErrorString(opaquePointer: gakPRIV!, mask: "gakPRIV")
            
            return nil
        } else {
            return addressPrivateKeyPointer.pointee
        }
    }
    
    func createAddress(currencyID: UInt32, walletID: UInt32, addressID: UInt32, binaryData: inout BinaryData) -> Dictionary<String, Any>? {
        let binaryDataPointer = UnsafeMutablePointer(mutating: &binaryData)
        let masterKeyPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mmk = make_master_key(binaryDataPointer, masterKeyPointer)
        print("mmk: \(String(describing: mmk))")
        
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
        
        let mHDa = make_hd_account(masterKeyPointer.pointee, Currency.init(currencyID), walletID, newAccountPointer)
        if mHDa != nil {
            print("mHDa: \(String(describing: mHDa))")
            
            return nil
        }
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_INTERNAL, addressID, newAddressPointer)
        if mHDa != nil {
            print("mHDla: \(String(describing: mHDla))")
            
            return nil
        }
        
        //Create wallet
        var addressDict = Dictionary<String, Any>()
        addressDict["currencyID"] = currencyID
        addressDict["walletIndex"] = walletID
        addressDict["addressIndex"] = addressID
        addressDict["addressPointer"] = newAddressPointer.pointee
        
        let gaas = get_account_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String? = nil
        if gaas != nil {
            print("Cannot get address string: \(String(describing: gaas))")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString)")
            
            addressDict["address"] = addressString!
        }
        
        let gakPRIV = get_account_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        let gakPUBL = get_account_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        
        print("\(gakPRIV) - \(gakPUBL) - \(ktsPRIV) - \(ktsPUBL)")
        
        var privateKeyString : String? = nil
        var publicKeyString : String? = nil
        
        if ktsPRIV != nil {
            print("Cannot get private string: \(String(describing: gaas))")
        } else {
            privateKeyString = String(cString: privateKeyStringPointer.pointee!)
            addressDict["privateKey"] = privateKeyString
            
            addressDict["addressPrivateKeyPointer"] = addressPublicKeyPointer.pointee
        }
        
        if ktsPUBL != nil {
            print("Cannot get public string: \(String(describing: gaas))")
        } else {
            publicKeyString = String(cString: publicKeyStringPointer.pointee!)
            addressDict["publicKey"] = publicKeyString
        }
        
        return addressDict
    }
    
    func createHDAccount(from masterKey: OpaquePointer)  {
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
        
        let mHDa = make_hd_account(masterKey, Currency.init(0), 0, newAccountPointer)
        print("mHDa: \(String(describing: mHDa))")
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_EXTERNAL, 0, newAddressPointer)
        print("mHDla: \(String(describing: mHDla))")
        
        let gaas = get_account_address_string(newAddressPointer.pointee, newAddressStringPointer)
        print("gaas: \(String(describing: gaas))")
        let addressString = String(cString: newAddressStringPointer.pointee!)
        
        print("addressString: \(addressString)")
        
        let gakPRIV = get_account_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        let gakPUBL = get_account_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        
        print("\(gakPRIV) - \(gakPUBL) - \(ktsPRIV) - \(ktsPUBL)")
        
        let privateKeyString = String(cString: privateKeyStringPointer.pointee!)
        let publicKeyString = String(cString: publicKeyStringPointer.pointee!)
        
        print("privateKeyString: \(privateKeyString)")
        print("publicKeyString: \(publicKeyString)")
        
        let currencyPointer = UnsafeMutablePointer<Currency>.allocate(capacity: 1)
        let gac = get_account_currency(newAddressPointer.pointee, currencyPointer)
        print("gac: \(gac)")
        
        let currency : Currency = currencyPointer.pointee
        print("currency: \(currency)")
        
        amountActivity()
//        createTransaction(addressPointer: newAddressPointer.pointee!, sendAddress: "", sendAmountString: "100000000", feeAmountString: "20000", donationAddress: "", donationAmount: "10000000", txid: "`x", txoutid: 1, txoutamount: 804, txoutscript: "a914bddce1db77593a7ac8d67f0d488c4311d5103ffa87")
    }
    
    func getTotalFee(addressPointer: OpaquePointer, feeAmountString: String, isDonationExists: Bool, isPayCommission: Bool , inputsCount: Int) -> UInt32 {
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mt = make_transaction(addressPointer, transactionPointer)
        if mt != nil {
            let _ = returnErrorString(opaquePointer: mt!, mask: "make_transaction")
        }
        
        //fee
        let fee = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgf = transaction_get_fee(transactionPointer.pointee, fee)
        if tgf != nil {
            let _ = returnErrorString(opaquePointer: tgf!, mask: "transaction_get_fee")
        }
        
        //Amount
        setAmountValue(key: "amount_per_byte", value: feeAmountString, pointer: fee.pointee!)
        
        let outputCount = 1 + (isDonationExists ? 1 : 0) + 1 //addresses: destination/donation/change
        
        let estimate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        let tet = transaction_estimate_total_fee(transactionPointer.pointee, inputsCount, outputCount, estimate)
        if tet != nil {
            let _ = returnErrorString(opaquePointer: tet!, mask: "transaction_estimate_total_fee")
        }
        
        let ats = amount_to_string(estimate.pointee, amountStringPointer)
        if ats != nil {
            let _ = returnErrorString(opaquePointer: ats!, mask: "amount_to_string")
        }
        
        let amountString = String(cString: amountStringPointer.pointee!)
        let feeSum = UInt32(amountString)!
        
        return feeSum
    }
    
    func getTotalFeeAndInputs(addressPointer: OpaquePointer, sendAmountString: String, feeAmountString: String, isDonationExists: Bool, donationAmount: String, isPayCommission: Bool , wallet: UserWalletRLM) -> (String,  [SpendableOutputRLM], String?) {
        
        //estimate number of ouputs
        var paySum = UInt32(Double(sendAmountString)! * pow(10, 8))
        
        let donationSum = UInt32(Double(donationAmount)! * pow(10, 8))
        
        if isPayCommission {
            paySum += donationSum
        }
        
        var inputSum = UInt32(0)
        var feeSum = UInt32(0)
        
        let inputs = DataManager.shared.fetchSpendableOutput(wallet: wallet)
        var greedyInputs = [SpendableOutputRLM]()
        
        repeat {
            greedyInputs = DataManager.shared.greedySubSet(outputs: inputs, threshold: paySum + feeSum)
            
            //create transaction
            let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            
            let mt = make_transaction(addressPointer, transactionPointer)
            if mt != nil {
                let _ = returnErrorString(opaquePointer: mt!, mask: "make_transaction")
            }
            
            //fee
            let fee = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            let tgf = transaction_get_fee(transactionPointer.pointee, fee)
            if tgf != nil {
                let _ = returnErrorString(opaquePointer: tgf!, mask: "transaction_get_fee")
            }
            
            //Amount
            setAmountValue(key: "amount_per_byte", value: feeAmountString, pointer: fee.pointee!)
//            setAmountValue(key: "max_amount_per_byte", value: feeAmountString, pointer: fee.pointee!) // optional
            //detect ouputs
            
            let outputCount = 1 + (isDonationExists ? 1 : 0) + 1 //addresses: destination/donation/change
            
            let estimate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
            let tet = transaction_estimate_total_fee(transactionPointer.pointee, greedyInputs.count, outputCount, estimate)
            if tet != nil {
                let _ = returnErrorString(opaquePointer: tet!, mask: "transaction_estimate_total_fee")
            }
            
            let ats = amount_to_string(estimate.pointee, amountStringPointer)
            if ats != nil {
                let _ = returnErrorString(opaquePointer: ats!, mask: "amount_to_string")
            }
            
            let amountString = String(cString: amountStringPointer.pointee!)
            feeSum = UInt32(amountString)!
            inputSum = DataManager.shared.spendableOutputSum(outputs: greedyInputs)
        } while (isPayCommission && inputSum <= paySum + feeSum && greedyInputs.count != inputs.count) || (!isPayCommission && paySum <= donationSum + feeSum && greedyInputs.count != inputs.count)
        
        
        //adding error message
        if greedyInputs.count != inputs.count {
            return (String(feeSum), greedyInputs, nil)
        } else {
            if isPayCommission {
                return (String(feeSum), greedyInputs, inputSum <= paySum + feeSum ? "Not enough" : nil)
            } else {
                return (String(feeSum), greedyInputs, paySum <= donationSum + feeSum ? "Not enough" : nil)
            }
        }
    }
    
    func createTransaction(addressPointer: OpaquePointer,
                           sendAddress: String,
                           sendAmountString: String,
                           feePerByteAmount: String,
                           isDonationExists: Bool,
                           donationAmount: String,
                           isPayCommission: Bool,
                           wallet: UserWalletRLM,
                           binaryData: inout BinaryData,
                           feeAmount: UInt32,
                           inputs: List<AddressRLM>) -> (String, Double) {
        
        let inputs = DataManager.shared.realmManager.spendableOutput(addresses: inputs)
        let inputSum = DataManager.shared.spendableOutputSum(outputs: inputs)
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mt = make_transaction(addressPointer, transactionPointer)
        if mt != nil {
            let _ = returnErrorString(opaquePointer: mt!, mask: "make_transaction")
        }
        
        //fee
        let fee = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgf = transaction_get_fee(transactionPointer.pointee, fee)
        if tgf != nil {
            let _ = returnErrorString(opaquePointer: tgf!, mask: "transaction_get_fee")
        }
        
        
        let maxFee = UInt32(feePerByteAmount)!
        let maxFeeString = String(maxFee + (maxFee / 5))// 20% error
        //Amount
        setAmountValue(key: "amount_per_byte", value: feePerByteAmount, pointer: fee.pointee!)
        setAmountValue(key: "max_amount_per_byte", value: maxFeeString, pointer: fee.pointee!) // optional

        //spendable info
        
        for input in inputs {
            let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            let tas = transaction_add_source(transactionPointer.pointee, transactionSource)
            
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
            
            let privateKey = createPrivateKey(currencyID: wallet.chain.uint32Value,
                                              walletID: wallet.walletID.uint32Value,
                                              addressID: input.addressID.uint32Value,
                                              binaryData: &binaryData)
            setPrivateKeyValue(key: "private_key", value: privateKey!, pointer: transactionSource.pointee!)
        }
        
        var sendSum = UInt32(0)
        var changeSum = UInt32(0)
        
        if isPayCommission {
            sendSum = convertBTCStringToSatoshi(sum: sendAmountString)
            changeSum = inputSum - (sendSum + convertBTCStringToSatoshi(sum: donationAmount) + feeAmount)
        } else {
            sendSum = convertBTCStringToSatoshi(sum: sendAmountString) - (convertBTCStringToSatoshi(sum: donationAmount) + feeAmount)
            changeSum = inputSum - convertBTCStringToSatoshi(sum: sendAmountString)
        }
        
        //address
        let transactionDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        transaction_add_destination(transactionPointer.pointee, transactionDestination)
        
        setStringValue(key: "address", value: sendAddress, pointer: transactionDestination.pointee!)
        setAmountValue(key: "amount", value: String(sendSum), pointer: transactionDestination.pointee!)
        
        //donation
        if isDonationExists {
            let donationDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            transaction_add_destination(transactionPointer.pointee, donationDestination)
            
            setStringValue(key: "address", value: donationAddress, pointer: donationDestination.pointee!)
            setAmountValue(key: "amount", value: String(convertBTCStringToSatoshi(sum: donationAmount)), pointer: donationDestination.pointee!)
        }
        
        //change
        //MARK: UInt32(wallet.addresses.count)
        let dict = createAddress(currencyID: wallet.chain.uint32Value,
                                 walletID: wallet.walletID.uint32Value,
                                 addressID: UInt32(wallet.addresses.count),
                                 binaryData: &binaryData)
        
        let changeDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        transaction_add_destination(transactionPointer.pointee, changeDestination)
        
        setStringValue(key: "address", value: dict!["address"] as! String, pointer: changeDestination.pointee!)
        setAmountValue(key: "amount", value: String(changeSum), pointer: changeDestination.pointee!)
        
        //final
        let serializedTransaction = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        
        let tu = transaction_update(transactionPointer.pointee)
        
        if tu != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tu)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tu: \(errrString))")
            
            return (errrString, -1)
        }
        
        let tSign = transaction_sign(transactionPointer.pointee)
        
        if tSign != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tSign)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tSign: \(errrString))")
            
            return (errrString, -1)
        }
        
        let tSer = transaction_serialize(transactionPointer.pointee, serializedTransaction)
        
        if tSer != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tSer)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tSer: \(errrString))")
            
            return (errrString, -1)
        }
        
        print("\(tu) -- \(tSign) -- \(tSer)")
        
        let data = serializedTransaction.pointee!.pointee.convertToData()
        let str = data.hexEncodedString()
        
        print("end transaction: \(str)")
        
        let totalSumPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgtf = transaction_get_total_fee(transactionPointer.pointee, totalSumPointer)
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        let ats = amount_to_string(totalSumPointer.pointee, amountStringPointer)
        if ats != nil {
            let _ = returnErrorString(opaquePointer: ats!, mask: "amount_to_string")
        }
        
        let amountString = String(cString: amountStringPointer.pointee!)
        let satoshiAmount = convertSatoshiToBTC(sum: UInt32(amountString)!)
        
        return (str, satoshiAmount)
        //        return ""
    }
    
    func createTransactionOld(addressPointer: OpaquePointer, sendAddress: String, sendAmountString: String, feeAmountString: String, isDonationExists: Bool, donationAmount: String, isPayCommission: Bool, wallet: UserWalletRLM, binaryData: inout BinaryData, inputs: (String,  [SpendableOutputRLM], String?)) -> (String, Double) {
        
        let inputSum = DataManager.shared.spendableOutputSum(outputs: inputs.1)
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        let mt = make_transaction(addressPointer, transactionPointer)
        if mt != nil {
            let _ = returnErrorString(opaquePointer: mt!, mask: "make_transaction")
        }
        
        //fee
        let fee = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgf = transaction_get_fee(transactionPointer.pointee, fee)
        if tgf != nil {
            let _ = returnErrorString(opaquePointer: tgf!, mask: "transaction_get_fee")
        }
        
        
        let maxFee = UInt32(feeAmountString)!
        let maxFeeString = String(maxFee + (maxFee / 10))
        //Amount
        setAmountValue(key: "amount_per_byte", value: feeAmountString, pointer: fee.pointee!)
        setAmountValue(key: "max_amount_per_byte", value: maxFeeString, pointer: fee.pointee!) // optional
        
        
        
        
        //detect ouputs
        
//        let estimate = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
//        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
//        let tet = transaction_estimate_total_fee(transactionPointer.pointee, 2, 2, estimate)
//        if tet != nil {
//            let _ = returnErrorString(opaquePointer: tet!, mask: "transaction_estimate_total_fee")
//        }
//
//        let ats = amount_to_string(estimate.pointee, amountStringPointer)
//        if ats != nil {
//            let _ = returnErrorString(opaquePointer: ats!, mask: "amount_to_string")
//        }
//        let amountString = String(cString: amountStringPointer.pointee!)

        
        
        
        
        //spendable info
        
        for input in inputs.1 {
            let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            let tas = transaction_add_source(transactionPointer.pointee, transactionSource)
            
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
            
            let privateKey = createPrivateKey(currencyID: 0,
                                              walletID: wallet.walletID.uint32Value,
                                              addressID: input.addressID.uint32Value,
                                              binaryData: &binaryData)
            setPrivateKeyValue(key: "private_key", value: privateKey!, pointer: transactionSource.pointee!)
        }
        
        var sendSum = UInt32(0)
        var changeSum = UInt32(0)
        
        if isPayCommission {
            sendSum = convertBTCStringToSatoshi(sum: sendAmountString)
            changeSum = inputSum - (convertBTCStringToSatoshi(sum: sendAmountString) + convertBTCStringToSatoshi(sum: donationAmount) + convertBTCStringToSatoshi(sum: inputs.0))
        } else {
            sendSum = convertBTCStringToSatoshi(sum: sendAmountString) - (convertBTCStringToSatoshi(sum: donationAmount) + convertBTCStringToSatoshi(sum: inputs.0))
            changeSum = inputSum - convertBTCStringToSatoshi(sum: sendAmountString)
        }
        
        //address
        let transactionDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        transaction_add_destination(transactionPointer.pointee, transactionDestination)
        
        setStringValue(key: "address", value: sendAddress, pointer: transactionDestination.pointee!)
        setAmountValue(key: "amount", value: String(sendSum), pointer: transactionDestination.pointee!)
        
        //donation
        if isDonationExists {
            let donationDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
            transaction_add_destination(transactionPointer.pointee, donationDestination)
            
            setStringValue(key: "address", value: donationAddress, pointer: donationDestination.pointee!)
            setAmountValue(key: "amount", value: String(convertBTCStringToSatoshi(sum: donationAmount)), pointer: donationDestination.pointee!)
        }
        
        //change
        //MARK: UInt32(wallet.addresses.count)
        let dict = createAddress(currencyID: wallet.chain.uint32Value, walletID: wallet.walletID.uint32Value, addressID: 0, binaryData: &binaryData)
        
        let changeDestination = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        transaction_add_destination(transactionPointer.pointee, changeDestination)

        setStringValue(key: "address", value: dict!["address"] as! String, pointer: changeDestination.pointee!)
        setAmountValue(key: "amount", value: String(changeSum), pointer: changeDestination.pointee!)
        
        //final
        let serializedTransaction = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        
        let tu = transaction_update(transactionPointer.pointee)
        
        if tu != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tu)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tu: \(errrString))")
        }
        
        let tSign = transaction_sign(transactionPointer.pointee)
        
        if tSign != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tSign)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tSign: \(errrString))")
        }
        
        let tSer = transaction_serialize(transactionPointer.pointee, serializedTransaction)
        
        if tSer != nil {
            let pointer = UnsafeMutablePointer<CustomError>(tSer)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("tSer: \(errrString))")
        }
        
        print("\(tu) -- \(tSign) -- \(tSer)")
        
        let data = serializedTransaction.pointee!.pointee.convertToData()
        let str = data.hexEncodedString()

        print("end transaction: \(str)")
        
        let totalSumPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let tgtf = transaction_get_total_fee(transactionPointer.pointee, totalSumPointer)
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        let ats = amount_to_string(totalSumPointer.pointee, amountStringPointer)
        if ats != nil {
            let _ = returnErrorString(opaquePointer: ats!, mask: "amount_to_string")
        }
        
        let amountString = String(cString: amountStringPointer.pointee!)
        let satoshiAmount = convertSatoshiToBTC(sum: UInt32(amountString)!)
        
        return (str, satoshiAmount)
//        return ""
    }
    
    func amountActivity() {
        let amount = "20".UTF8CStringPointer
        let anotherAmount = "30".UTF8CStringPointer

        let newAmount = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let amountStringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>.allocate(capacity: 1)
        
        let ma = make_amount(amount, newAmount)
        let ats = amount_to_string(newAmount.pointee, amountStringPointer)
        let asv = amount_set_value(newAmount.pointee, anotherAmount)
//        free_amount(newAmount.pointee)
        print("amountActivity: \(ma) -- \(ats) -- \(asv)")
    }
    
    ////////////////////////////////////
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
        
        var mki = make_key_id(masterKeyPointer.pointee, extendedKeyPointer)
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
        
        let mHDa = make_hd_account(masterKeyPointer.pointee, Currency.init(0), 0, newAccountPointer)
        print("make_hd_account: \(mHDa)")
        
        let mHDla = make_hd_leaf_account(newAccountPointer.pointee, ADDRESS_INTERNAL, 0, newAddressPointer)
        print("make_hd_leaf_account: \(mHDla)")
        
        //Create wallet
        
        let gaas = get_account_address_string(newAddressPointer.pointee, newAddressStringPointer)
        var addressString : String? = nil
        if gaas != nil {
            print("Cannot get address string: \(String(describing: gaas))")
        } else {
            addressString = String(cString: newAddressStringPointer.pointee!)
            print("addressString: \(addressString!)")
        }
        
        let gakPRIV = get_account_key(newAddressPointer.pointee, KEY_TYPE_PRIVATE, addressPrivateKeyPointer)
        let gakPUBL = get_account_key(newAddressPointer.pointee, KEY_TYPE_PUBLIC, addressPublicKeyPointer)
        
        let ktsPRIV = key_to_string(addressPrivateKeyPointer.pointee, privateKeyStringPointer)
        let ktsPUBL = key_to_string(addressPublicKeyPointer.pointee, publicKeyStringPointer)
        
        print("\(gakPRIV) - \(gakPUBL) - \(ktsPRIV) - \(ktsPUBL)")
        
        
        let currencyPointer = UnsafeMutablePointer<Currency>.allocate(capacity: 1)
        let gac = get_account_currency(newAddressPointer.pointee, currencyPointer)
        print("gac: \(gac)")
        
        let currency : Currency = currencyPointer.pointee
        print("another currency: \(currency)")
        
        //create transaction
        let transactionPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let transactionSource = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        
        
        let mt = make_transaction(newAddressPointer.pointee, transactionPointer)
        if mt != nil {
            let pointer = UnsafeMutablePointer<CustomError>(mt)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("\(errrString) -- \(UINT64_MAX)")
        }
        
        print("END")
    }
    
    func setAmountValue(key: String, value: String, pointer: OpaquePointer) {
        let amountKey = key.UTF8CStringPointer
        let amountValue = value.UTF8CStringPointer
        
        let amountPointer = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: 1)
        let _ = make_amount(amountValue, amountPointer)
        
        let psav = properties_set_amount_value(pointer, amountKey, amountPointer.pointee)
        
        if psav != nil {
            let pointer = UnsafeMutablePointer<CustomError>(psav)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("setAmountValue: \(errrString))")
        }
    }
    
    func setBinaryDataValue(key: String, value: String, pointer: OpaquePointer) {
        let binaryKey = key.UTF8CStringPointer
        let dataValue = value.UTF8CStringPointer
        
        let binData = UnsafeMutablePointer<UnsafeMutablePointer<BinaryData>?>.allocate(capacity: 1)
        make_binary_data_from_hex(dataValue, binData)
        
        let psbdv = properties_set_binary_data_value(pointer, binaryKey, binData.pointee)
        if psbdv != nil {
            let pointer = UnsafeMutablePointer<CustomError>(psbdv)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("setBinaryDataValue: \(errrString))")
        }
    }
    
    func setIntValue(key: String, value: UInt32, pointer: OpaquePointer) {
        let intKey = key.UTF8CStringPointer
        let intValue = Int32(value)

        let psi = properties_set_int32_value(pointer, intKey, intValue)
        
        if psi != nil {
            let pointer = UnsafeMutablePointer<CustomError>(psi)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("setIntValue: \(errrString))")
        }
    }
    
    func setStringValue(key: String, value: String, pointer: OpaquePointer) {
        let stringKey = key.UTF8CStringPointer
        let stringValue = value.UTF8CStringPointer
        
        let pstv = properties_set_string_value(pointer, stringKey, stringValue)
        
        if pstv != nil {
            let pointer = UnsafeMutablePointer<CustomError>(pstv)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("setStringValue: \(errrString))")
        }
    }
    
    func setPrivateKeyValue(key: String, value: OpaquePointer, pointer: OpaquePointer) {
        let stringKey = key.UTF8CStringPointer
        
        let pspkv = properties_set_private_key_value(pointer, stringKey, value)
        
        if pspkv != nil {
            let pointer = UnsafeMutablePointer<CustomError>(pspkv)
            let errrString = String(cString: pointer!.pointee.message)
            
            print("setPrivateKeyValue: \(errrString))")
        }
    }
    
    func returnErrorString(opaquePointer: OpaquePointer, mask: String) -> String {
        let pointer = UnsafeMutablePointer<CustomError>(opaquePointer)
        let errorString = String(cString: pointer.pointee.message)
        
        print("\(mask): \(errorString))")
        
        return errorString
    }
}
