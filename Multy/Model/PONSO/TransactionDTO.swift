//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class TransactionDTO: NSObject {
    var sendAddress : String?
    var sendAmount: Double?
    var sendAmountString: String?
    var choosenWallet: UserWalletRLM? {
        didSet {
            if choosenWallet != nil {
                currencyID = choosenWallet?.chain
                blockchainType = BlockchainType.create(wallet: choosenWallet!)
            }
        }
    }
    
    var blockchainType: BlockchainType? {
        didSet {
            if blockchainType != nil {
                blockchain = blockchainType!.blockchain
            }
        }
    }
    var blockchain: Blockchain?
    
    var currencyID : NSNumber? {
        didSet {
            createTransactionDTO()
        }
    }
    
    var transaction: BaseTransactionDTO?
    
    func createTransactionDTO() {
        switch currencyID?.uint32Value {
        case BLOCKCHAIN_BITCOIN.rawValue?:
            transaction = BTCTransactionDTO()
        case BLOCKCHAIN_ETHEREUM.rawValue?:
            transaction = ETHTransactionDTO()
        default:
            transaction = BTCTransactionDTO()
        }
    }
    
    func update(from qrString: String) {
        let array = qrString.components(separatedBy: CharacterSet(charactersIn: ":?="))
        switch array.count {
        case 1:
            sendAddress = array[0]
        case 2:                              // chain name + address
            let blockchainName = array[0]
            sendAddress = array[1]
            blockchain = Blockchain.blockchainFromString(blockchainName)
        case 4:                                // chain name + address + amount
            let blockchainName = array[0]
            sendAddress = array[1]
            sendAmountString = array[3]
            sendAmount = (sendAmountString! as NSString).doubleValue
            blockchain = Blockchain.blockchainFromString(blockchainName)
        default:
            return
        }
    }
}

class BaseTransactionDTO {
    var finalSendSum: Double?
    var donationDTO: DonationDTO?
    var transactionRLM: TransactionRLM?
    var customFee: UInt64?
    var rawTransaction: String?
    var newChangeAddress: String?
    var endSum: Double?
    var endSumBigInt: BigInt?
    var customGAS: EthereumGasInfo?
    var feeAmount = BigInt("0")
}

class BTCTransactionDTO: BaseTransactionDTO {
    
}

class ETHTransactionDTO: BaseTransactionDTO {
    
}

class GOLOSTransactionDTO: BaseTransactionDTO {
    
}
