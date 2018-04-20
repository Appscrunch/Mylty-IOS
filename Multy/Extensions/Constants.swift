//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

struct Constants {
    //Assets screen
    struct AssetsScreen {
        static let progressString = "Getting Wallets..."
        static let createWalletString = "Create wallet"
        static let createOrImportWalletString = "Create or Import New Wallet"
        static let cancelString = "Cancel"
        static let backupButtonHeight = CGFloat(44)
        static let backupAssetsOffset = CGFloat(25)
    }
    
    struct ETHWalletScreen {
        static let topCellHeight = CGFloat(375)
        static let blockedCellDifference = CGFloat(60) // difference in table cell sizes in case existing/non existing blocked amount on wallet
        static let collectionCellDifference = CGFloat(137) // difference in sizes btw table cell and collection cell
    }
    
    //Scurity strings
    struct Security {
        static let jailbrokenDeviceWarningString = "Your Device is Jailbroken!\nSory, but we don`t support jailbroken devices."
    }
    
    //StoryboardStrings
    struct Storyboard {
        //Assets
        static let createWalletVCSegueID = "createWalletVC"
    }
    
    struct UserDefaults {
        //Config constants
        
        static let apiVersionKey =         "apiVersion"
        static let hardVersionKey =        "hardVersion"
        static let softVersionKey =        "softVersion"
        static let serverTimeKey =         "serverTime"
        static let stocksKey =             "stocks"
        static let btcDonationAddressesKey =  "donationAddresses"
    }
    
    struct DataManager {
        static let btcTestnetDonationAddress =  "mnUtMQcs3s8kSkSRXpREVtJamgUCWpcFj4"
        
        static let availableBlockchains = [
            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN.rawValue, netType: BITCOIN_NET_TYPE_MAINNET.rawValue),
            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN.rawValue, netType: BITCOIN_NET_TYPE_TESTNET.rawValue),
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM.rawValue, netType: UInt32(ETHEREUM_CHAIN_ID_MAINNET.rawValue)),
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM.rawValue, netType: UInt32(ETHEREUM_CHAIN_ID_RINKEBY.rawValue)),
        ]
        
        static let donationBlockchains = [
//            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM.rawValue,         netType: UInt32(ETHEREUM_CHAIN_ID_MAINNET.rawValue)),
            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN_LIGHTNING.rawValue,netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_GOLOS.rawValue,            netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_STEEM.rawValue,            netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_BITSHARES.rawValue,        netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN_CASH.rawValue,     netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_LITECOIN.rawValue,         netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_DASH.rawValue,             netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM_CLASSIC.rawValue, netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_ERC20.rawValue,            netType: 0),
        ]
    }
}

let defaultDelimeter = "," as Character

let screenSize = UIScreen.main.bounds
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

//Devices Heights
let heightOfX        : CGFloat = 812.0
let heightOfPlus     : CGFloat = 736.0
let heightOfStandard : CGFloat = 667.0
let heightOfFive     : CGFloat = 568.0
let heightOfiPad     : CGFloat = 480.0
//

//createWallet, WalletSettingd
let maxNameLength = 25

//brick view
let segmentsCountUp : Int  = 7
let segmentsCountDown : Int  = 8
let upperSizes : [CGFloat] = [0, 35, 79, 107, 151, 183, 218, 253]
let downSizes : [CGFloat] = [0, 23, 40, 53, 81, 136, 153, 197, 249]

let statuses = ["createdTx", "fromSocketTx", "incoming in mempool", "spend in mempool", "incoming in block", "spend in block", "in block confirmed", "rejected block"]

var isNeedToAutorise = false
var isViewPresented = false

func convertSatoshiToBTCString(sum: UInt64) -> String {
    return (Double(sum) / pow(10, 8)).fixedFraction(digits: 8) + " BTC"
}

func convertSatoshiToBTC(sum: Double) -> String {
    return (sum / pow(10, 8)).fixedFraction(digits: 8)
}

func convertBTCStringToSatoshi(sum: String) -> UInt64 {
    return UInt64(sum.convertStringWithCommaToDouble() * pow(10, 8))
}

func convertBTCToSatoshi(sum: String) -> Double {
    return sum.convertStringWithCommaToDouble() * pow(10, 8)
}

func shakeView(viewForShake: UIView) {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 4
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: viewForShake.center.x - 10, y: viewForShake.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: viewForShake.center.x + 10, y: viewForShake.center.y))
    
    viewForShake.layer.add(animation, forKey: "position")
//    self.viewWithCircles.layer.add(animation, forKey: "position")
}

enum TxStatus : Int {
    case
        MempoolIncoming =           1,
        BlockIncoming =             2,
        MempoolOutcoming =          3,
        BlockOutcoming =            4,
        BlockConfirmedIncoming =    5,
        BlockConfirmedOutcoming =   6
}

let minSatoshiInWalletForDonate: UInt64 = 10000 //10k minimun sum in wallet for available donation
let minSatoshiToDonate: UInt64          = 5000  //5k minimum sum to donate

//API REST constants
//let apiUrl = "http://88.198.47.112:2278/"//"http://192.168.0.121:7778/"
let shortURL = "test.multy.io"
let apiUrl = "https://\(shortURL)/"
let socketUrl = "wss://\(shortURL)/"
//let socketUrl = "http://88.198.47.112:2280"
let apiUrlTest = "http://192.168.0.123:6778/"
let nonLocalURL = "http://88.198.47.112:7778/"
