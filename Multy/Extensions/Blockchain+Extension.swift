//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

extension Blockchain {
    static func blockchainFromString(_ string: String) -> Blockchain {
        switch string {
        case Constants.BlockchainString.bitcoinKey:
            return BLOCKCHAIN_BITCOIN
        case Constants.BlockchainString.ethereumKey:
            return BLOCKCHAIN_ETHEREUM
        default:
            return BLOCKCHAIN_BITCOIN
        }
    }
    
    var multiplyerToMinimalUnits: BigInt {
        get {
            switch self {
            case BLOCKCHAIN_BITCOIN:
                return Constants.BigIntSwift.oneBTCInSatoshiKey
            case BLOCKCHAIN_ETHEREUM:
                return Constants.BigIntSwift.oneETHInWeiKey
            default:
                return BigInt("0")
            }
        }
    }

    var dividerFromCryptoToFiat: BigInt {
        get {
            switch self {
            case BLOCKCHAIN_BITCOIN:
                return Constants.BigIntSwift.oneCentiBitcoinInSatoshiKey
            case BLOCKCHAIN_ETHEREUM:
                return Constants.BigIntSwift.oneHundredFinneyKey
            default:
                return BigInt("0")
            }
        }
    }

    var shortName : String {
        var shortName = ""
        
        switch self {
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
        
        switch self {
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
        
        switch self {
        case BLOCKCHAIN_BITCOIN:
            //https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
            fullName = Constants.BlockchainString.bitcoinKey
        case BLOCKCHAIN_LITECOIN:
            fullName = "litecoin"
        case BLOCKCHAIN_DASH:
            fullName = "dash"
        case BLOCKCHAIN_ETHEREUM:
            fullName = Constants.BlockchainString.ethereumKey
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
    
    var maxLengthForSum: Int {
        var maxLenght = 0
        
        switch self {
        case BLOCKCHAIN_BITCOIN:
            maxLenght = 12
        case BLOCKCHAIN_LITECOIN:
            maxLenght = 0
        case BLOCKCHAIN_DASH:
            maxLenght = 0
        case BLOCKCHAIN_ETHEREUM:
            maxLenght = 12
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            maxLenght = 0
        case BLOCKCHAIN_STEEM:
            maxLenght = 0
        case BLOCKCHAIN_BITCOIN_CASH:
            maxLenght = 0
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            maxLenght = 0
        case BLOCKCHAIN_GOLOS:
            maxLenght = 0
        case BLOCKCHAIN_BITSHARES:
            maxLenght = 0
        case BLOCKCHAIN_ERC20:
            maxLenght = 0
        default:
            maxLenght = 0
        }
        
        return maxLenght
    }
    
    var maxPrecision: Int {
        var maxLenght = 0
        
        switch self {
        case BLOCKCHAIN_BITCOIN:
            maxLenght = 8
        case BLOCKCHAIN_LITECOIN:
            maxLenght = 0
        case BLOCKCHAIN_DASH:
            maxLenght = 0
        case BLOCKCHAIN_ETHEREUM:
            maxLenght = 18
        case BLOCKCHAIN_ETHEREUM_CLASSIC:
            maxLenght = 0
        case BLOCKCHAIN_STEEM:
            maxLenght = 0
        case BLOCKCHAIN_BITCOIN_CASH:
            maxLenght = 0
        case BLOCKCHAIN_BITCOIN_LIGHTNING:
            maxLenght = 0
        case BLOCKCHAIN_GOLOS:
            maxLenght = 0
        case BLOCKCHAIN_BITSHARES:
            maxLenght = 0
        case BLOCKCHAIN_ERC20:
            maxLenght = 0
        default:
            maxLenght = 0
        }
        
        return maxLenght
    }
}
