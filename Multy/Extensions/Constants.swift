//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit

private typealias LocalizeDelegate = Constants

struct Constants {
    static let yesString = "YES STRING"
    static let noString = "NO STRING"
    
    static let cryptoPortfolioString = "CRYPTO PORTFOLIO"
    static let currenciesChartsString = "CURRENCIES CHARTS"
    static let jailbrokenDeviceWarningString = "JAILBROKEN DEVICE ALERT MESSAGE"
    static let backupNeededString = "BACKUP IS NEEDED"
    static let restoreMultyString = "RESTORE MULTY"
    static let gettingWalletString = "GETTING WALLET"
    static let creatingWalletString = "CREATING WALLET"
    static let checkingVersionString = "CHECKING VERSION"
    static let availableString = "AVAILABLE"
    static let workInProgressString = "WORK IN PROGRESS"
    static let weHaveUpdateString = "WE HAVE AN UPDATE"
    static let updateMultyString = "UPDATE MULTY"
    static let goToUpdateString = "GO TO UPDATE"
    static let warningString = "WARNING"
    static let cancelString = "CANCEL"
    static let errorString = "ERROR"
    static let walletNameAlertString = "WALLET NAME NOT EMPTY ALERT"
    static let walletAmountAlertString = "WALLET AMOUNT ALERT"
    static let deleteWalletAlertString = "DELETE WALLET WARNING"
    static let copyToClipboardString = "COPY TO CLIPBOARD"
    static let shareString = "SHARE"
    static let magicalReceiveString = "MAGICAL RECEIVE"
    static let transactionInfoString = "TRANSACTION INFO"
    static let confirmationString = "CONFIRMATION"
    static let confirmationsString = "CONFIRMATIONS"
    static let notValidAddressString = "NOT VALID ADDRESS"
    static let goToSettingsString = "GO TO SETTINGS"
    static let recentAddressesString = "RECENT ADDRESSES"
    static let veryFastString = "VERY FAST";
    static let fastString = "FAST";
    static let mediumString = "MEDIUM";
    static let slowString = "SLOW";
    static let verySlowString = "VERY SLOW";
    static let customString = "CUSTOM";
    static let predefinedValueMessageString = "PREDEFINED VALUE MESSAGE"
    static let pleaseChooseFeeRate = "PLEASE CHOOSE FEE RATE"
    static let moreThenYouHaveString = "MORE THEN YOU HAVE"
    static let feeRateLessThenString = "FEE RATE LESS THEN"
    static let satoshiPerByteString = "SATOSHI PER BYTE"
    static let satoshiPerByteShortString = "SAT/B"
    static let feeTooHighString = "FEE TOO HIGH"
    static let gasPriceLess1String = "GAS PRICE LESS 1"
    static let successString = "SUCCESS"
    static let doneString = "DONE"
    static let errorSendingTxString = "ERROR WHILE SENDING TX"
    static let transactionErrorString = "TRANSACTION ERROR"
    static let backupSeedPhraseNeededString = "BACKUP NEEDED"
    static let viewSeedPhraseString = "VIEW SEED PHRASE"
    static let areYouSureString = "ARE YOU SURE"
    static let continueString = "CONTINUE"
    static let nextWordString = "NEXT WORD"
    static let from15String = "FROM 15"
    static let orString = "OR"
    static let wantToCancelString = "WANT TO CANCEL"
    static let repeatPINCodeString = "REPEAT PIN-CODE"
    static let sorryString = "SORRY"
    static let noInternetString = "NO INTERNET"
    static let connectDeviceString = "CONNECT DEVICE"
    static let somethingWentWrongString = "SOMETHING WENT WRONG"
    static let loadingString = "LOADING"
    static let unableToSendString = "UNABLE SEND"
    static let receiveString = "RECEIVE"
    static let activeRequestsString = "ACTIVE REQUESTS"
    static let youDontHaveWalletString = "YOU DONT HAVE WALLETS"
    static let enterSatoshiPerByte = "ENTER SATOSHI PER BYTE"
    static let enableBluetoothAlertTitle = "ENABLE BLUETOOTH ALERT TITLE"
    static let settingsActionTitle = "SETTINGS ACTION TITLE"
    static let sendTipString = "SEND TIP"
    static let useTermsOfService = "USE TERMS OF SERVICE"
    static let restoringWalletsString = "RESTORING WALLETS"
    static let cannotChooseEmptyWalletString = "CANNOT CHOOSE EMPTY WALLET"
    static let enterNonZeroAmountString = "ENTER NON-ZERO AMOUNT"
    static let youCantEnterSumString = "YOU CANT ENTER SUM"
    static let youEnteredTooSmallAmountString = "YOU ENTERED TOO SMALL AMOUNT"
    static let youTryingSpendMoreThenHaveString = "YOU ARE TRYING SPEND MORE THEN HAVE"
    static let updatingString = "UPDATING"
    static let sendingString = "SENDING"
    static let deletingString = "DELETING"
    static let agreeWithTermsString = "AGREE WITH TERMS"
    static let scanningNotSupportedString = "SCANNING NOT SUPPORTED"
    static let deviceNotSupportingString = "DEVICE NOT SUPPORT"
    static let notEnoughAmountString = "NOT ENOUGH AMOUNT"
    static let pleaseChooseGasPriceString = "PLEASE CHOOSE GAS PRICE"
    static let youCanUsePredefinedValueString = "YOU CAN USE PREDEFINED VALUE"
    static let trySendZeroString = "TRY TO SEND ZERO"
    static let enterCorrectValueString = "ENTER CORRECT VALUE"
    static let noFundsString = "NO FUNDS"
    static let errorWhileCreatingWalletString = "ERROR WHILE CREATING WALLET"
    static let youCantSpendMoreThanFeeAndDonationString = "YOU CANT SPEND MORE THEN FEE AND DONATION"
    static let youCantSpendMoreThanFeeString = "YOU CANT SPEND MORE THEN FEE"
    static let andDonationString = "AND DONATION "
    
    //Assets screen
    struct AssetsScreen {
        static let createWalletString = "Create wallet"
        static let backupButtonHeight = CGFloat(44)
        static let backupAssetsOffset = CGFloat(25)
        static let leadingAndTrailingOffset = CGFloat(16)
    }
    
    struct ETHWalletScreen {
        static let topCellHeight = CGFloat(331)
        static let blockedCellDifference = CGFloat(60) // difference in table cell sizes in case existing/non existing blocked amount on wallet
        static let collectionCellDifference = CGFloat(137) // difference in sizes btw table cell and collection cell
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
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM.rawValue, netType: UInt32(ETHEREUM_CHAIN_ID_RINKEBY.rawValue)),
        ]
        
        static let donationBlockchains = [
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM.rawValue, netType: UInt32(ETHEREUM_CHAIN_ID_MAINNET.rawValue)),
//            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN_LIGHTNING.rawValue,netType: 0),
//            BlockchainType.create(currencyID: BLOCKCHAIN_GOLOS.rawValue,            netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_STEEM.rawValue,            netType: 0),
//            BlockchainType.create(currencyID: BLOCKCHAIN_BITSHARES.rawValue,        netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_BITCOIN_CASH.rawValue,     netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_LITECOIN.rawValue,         netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_DASH.rawValue,             netType: 0),
            BlockchainType.create(currencyID: BLOCKCHAIN_ETHEREUM_CLASSIC.rawValue, netType: 0),
//            BlockchainType.create(currencyID: BLOCKCHAIN_ERC20.rawValue,            netType: 0),
        ]
    }
    
    struct BigIntSwift {
        static let oneETHInWeiKey = BigInt("1000000000000000000") // 1 ETH = 10^18 Wei
        static let oneHundredFinneyKey = BigInt("10000000000000000") // 10^{-2} ETH
        
        static let oneBTCInSatoshiKey = BigInt("100000000") // 1 BTC = 10^8 Satoshi
        static let oneCentiBitcoinInSatoshiKey = BigInt("1000000") // 10^{-2} BTC
    }
    
    struct BlockchainString {
        static let bitcoinKey = "bitcoin"
        static let ethereumKey = "ethereum"
    }
    
    struct CustomFee {
        static let defaultBTCCustomFeeKey = 2
        static let defaultETHCustomFeeKey = 1 // in GWei
    }
}

extension LocalizeDelegate: Localizable {
    var tableName: String {
        return "Assets"
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

let infoPlist = Bundle.main.infoDictionary!

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
    return UInt64(sum.toStringWithZeroes(precision: 8))!
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

let HUDFrame = CGRect(x: screenWidth / 2 - 70,   // width / 2
                      y: screenHeight / 2 - 60,  // height / 2
                      width: 145,
                      height: 120)

let idOfInapps = ["io.multy.addingActivity5", "io.multy.addingCharts5", "io.multy.addingContacts5",
                  "io.multy.addingDash5", "io.multy.addingEthereumClassic5", "io.multy.addingExchange5",
                  "io.multy.exchangeStocks", "io.multy.importWallet5", "io.multy.addingLitecoin5",
                  "io.multy.addingPortfolio5", "io.multy.addingSteemit5", "io.multy.wirelessScan5",
                  "io.multy.addingBCH5", "io.multy.estimationCurrencies5", "io.multy.addingEthereum5"]

let idOfInapps50 = ["io.multy.addingActivity50", "io.multy.addingCharts50", "io.multy.addingContacts50",
                  "io.multy.addingDash50", "io.multy.addingEthereumClassic50", "io.multy.addingExchange50",
                  "io.multy.exchangeStocks50", "io.multy.importWallet50", "io.multy.addingLitecoin50",
                  "io.multy.addingPortfolio50", "io.multy.addingSteemit50", "io.multy.wirelessScan50",
                  "io.multy.addingBCH50", "io.multy.estimationCurrencie50", "io.multy.addingEthereum50"]

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

let shortURL = "api.multy.io"
let apiUrl = "https://\(shortURL)/"
let socketUrl = "wss://\(shortURL)/"
//JACK
//let shortURL = "192.168.31.146"
//let apiUrl = "http://\(shortURL):6778/"
//let socketUrl = "ws://\(shortURL):6780/"
//let socketUrl = "ws://192.168.31.147:6780"
//let socketUrl = "http://88.198.47.112:2280"
let apiUrlTest = "http://192.168.0.123:6778/"
let nonLocalURL = "http://88.198.47.112:7778/"

// Bluetooth
let BluetoothSettingsURL_iOS9 = "prefs:root=Bluetooth"
let BluetoothSettingsURL_iOS10 = "App-Prefs:root=Bluetooth"

