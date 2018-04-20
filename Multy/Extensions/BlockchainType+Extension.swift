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
        var shortName = ""
        
        switch self.blockchain {
        case BLOCKCHAIN_BITCOIN:
            shortName = "BTC"
        case BLOCKCHAIN_LITECOIN:
            shortName = "LTC"
        case BLOCKCHAIN_DASH:
            shortName = "DASH"
        case BLOCKCHAIN_ETHEREUM:
            shortName = "ETH"
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            shortName = "ETC"
        case BLOCKCHAIN_STEEM:
            shortName = "STEEM"
        case BLOCKCHAIN_BITCOIN_CASH:
            shortName = "BCH"
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            shortName = "LBTC"
        case BLOCKCHAIN_GOLOS:
            shortName = "GOLOS"
        case BLOCKCHAIN_BITSHARES:
            shortName = "BTS"
        case BLOCKCHAIN_ERC20:
            shortName = "ERC20"
        default:
            shortName = ""
        }
        
        return shortName
    }
    
    var fullName : String {
        var fullName = ""
        
        switch self.blockchain {
        case BLOCKCHAIN_BITCOIN:
            fullName = "Bitcoin"
        case BLOCKCHAIN_LITECOIN:
            fullName = "Litecoin"
        case BLOCKCHAIN_DASH:
            fullName = "Dash"
        case BLOCKCHAIN_ETHEREUM:
            fullName = "Ethereum"
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            fullName = "Ethereum Classic"
        case BLOCKCHAIN_STEEM:
            fullName = "Steem Dollars"
        case BLOCKCHAIN_BITCOIN_CASH:
            fullName = "Bitcoin Cash"
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            fullName = "Bitcoin lightning"
        case BLOCKCHAIN_GOLOS:
            fullName = "Golos"
        case BLOCKCHAIN_BITSHARES:
            fullName = "BitShares"
        case BLOCKCHAIN_ERC20:
            fullName = "ERC20 Tokens"
        default:
            fullName = ""
        }
        
        return fullName
    }
    
    var qrBlockchainString : String {
        var fullName = ""
        
        switch self.blockchain {
        case BLOCKCHAIN_BITCOIN:
            //https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
            fullName = "bitcoin"
        case BLOCKCHAIN_LITECOIN:
            fullName = "litecoin"
        case BLOCKCHAIN_DASH:
            fullName = "dash"
        case BLOCKCHAIN_ETHEREUM:
            fullName = "ethereum"
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            fullName = ""
        case BLOCKCHAIN_STEEM:
            fullName = ""
        case BLOCKCHAIN_BITCOIN_CASH:
            fullName = ""
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            fullName = ""
        case BLOCKCHAIN_GOLOS:
            fullName = ""
        case BLOCKCHAIN_BITSHARES:
            fullName = ""
        case BLOCKCHAIN_ERC20:
            fullName = ""
        default:
            fullName = ""
        }
        
        return fullName
    }
    
    static func create(wallet: UserWalletRLM) -> BlockchainType {
        return BlockchainType.create(currencyID: wallet.chain.uint32Value, netType: wallet.chainType.uint32Value)
    }
    
    static func create(currencyID: UInt32, netType: UInt32) -> BlockchainType {
        return BlockchainType.init(blockchain: Blockchain.init(currencyID), net_type: Int(netType))
    }
}
