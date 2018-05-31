//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

typealias BlockchainTypeEquatable = BlockchainType

extension BlockchainTypeEquatable: Equatable {
    static public func == (lhs: BlockchainType, rhs: BlockchainType) -> Bool {
        return lhs.blockchain.rawValue == rhs.blockchain.rawValue && lhs.net_type == rhs.net_type
    }
}

// MARK: MUST READ
// for every new blockchain entity we have to update all calculated properties:
// iconString, shortName, fullName, qrBlockchainString
extension BlockchainType {
    var isMainnet: Bool {
        switch self.blockchain {
        case BLOCKCHAIN_BITCOIN:
            switch UInt32(self.net_type) {
            case BITCOIN_NET_TYPE_MAINNET.rawValue:
                return true
            case BITCOIN_NET_TYPE_TESTNET.rawValue:
                return false
            default:
                return false
            }
        case BLOCKCHAIN_ETHEREUM:
            switch Int32(self.net_type) {
            case ETHEREUM_CHAIN_ID_MAINNET.rawValue:
                return true
            case ETHEREUM_CHAIN_ID_RINKEBY.rawValue:
                return false
            default:
                return false
            }
        default:
            return true
        }
    }
    
    var iconString : String {
        var iconString = ""
        
        switch self.blockchain {
        case BLOCKCHAIN_BITCOIN:
            switch UInt32(self.net_type) {
            case BITCOIN_NET_TYPE_MAINNET.rawValue:
                iconString = "btcIconBig"
            case BITCOIN_NET_TYPE_TESTNET.rawValue:
                iconString = "btcTest"
            default:
                iconString = ""
            }
        case BLOCKCHAIN_LITECOIN:
            iconString = "chainLtc"
        case BLOCKCHAIN_DASH:
            iconString = "chainDash"
        case BLOCKCHAIN_ETHEREUM:
            switch Int32(self.net_type) {
            case ETHEREUM_CHAIN_ID_MAINNET.rawValue:
                iconString = "ethMediumIcon"
            case ETHEREUM_CHAIN_ID_RINKEBY.rawValue:
                iconString = "ethTest"
            default:
                iconString = ""
            }
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            iconString = "chainEtc"
        case BLOCKCHAIN_STEEM:
            iconString = "chainSteem"
        case BLOCKCHAIN_BITCOIN_CASH:
            iconString = "chainBch"
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            iconString = "chainLbtc"
        case BLOCKCHAIN_GOLOS:
            iconString = "chainGolos"
        case BLOCKCHAIN_BITSHARES:
            iconString = "chainBts"
        case BLOCKCHAIN_ERC20:
            iconString = "chainErc20"
        default:
            iconString = ""
        }
        
        return iconString
    }
    
    var shortName : String {
        return blockchain.shortName
    }
    
    var fullName : String {
        return blockchain.fullName
    }
    
    var qrBlockchainString : String {
        return blockchain.qrBlockchainString
    }
    
    static func create(wallet: UserWalletRLM) -> BlockchainType {
        return BlockchainType.create(currencyID: wallet.chain.uint32Value, netType: wallet.chainType.uint32Value)
    }
    
    static func create(currencyID: UInt32, netType: UInt32) -> BlockchainType {
        return BlockchainType.init(blockchain: Blockchain.init(currencyID), net_type: Int(netType))
    }
}
