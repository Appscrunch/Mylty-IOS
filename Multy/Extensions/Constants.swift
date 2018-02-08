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
}

let screenSize = UIScreen.main.bounds
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

//brick view
let segmentsCountUp : Int  = 7
let segmentsCountDown : Int  = 8
let upperSizes : [CGFloat] = [0, 35, 79, 107, 151, 183, 218, 253]
let downSizes : [CGFloat] = [0, 23, 40, 53, 81, 136, 153, 197, 249]

let statuses = ["createdTx", "fromSocketTx", "incoming in mempool", "spend in mempool", "incoming in block", "spend in block", "in block confirmed", "rejected block"]

func shouldUpdate(fromStatus: Int, toStatus: Int) -> Bool {
    return true
}

//var exchangeCourse: Double = 10000.0
var exchangeCourse: Double = 1.0 {
    didSet {
        NotificationCenter.default.post(name: NSNotification.Name("exchageUpdated"), object: nil)
    }
}

var isNeedToAutorise = false
var isViewPresented = false

func generateWalletPrimaryKey(currencyID: UInt32, walletID: UInt32) -> String {
    let currencyString = String(currencyID).sha3(.sha256)
    let walletString = String(walletID).sha3(.sha256)
    
    return ("\(currencyString)" + "\(walletString)").sha3(.sha256)
}

func convertSatoshiToBTC(sum: UInt32) -> Double {
    return Double(sum) / pow(10, 8)
}

func convertBTCStringToSatoshi(sum: String) -> UInt32 {
    return UInt32(sum.toStringWithComma() * pow(10, 8))
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

//API REST constants
//let apiUrl = "http://88.198.47.112:2278/"//"http://192.168.0.121:7778/"
let apiUrl = "https://test.multy.io/"
let socketUrl = "wss://test.multy.io/"
//let socketUrl = "http://88.198.47.112:2280"
let apiUrlTest = "http://192.168.0.125:8080/"
let nonLocalURL = "http://88.198.47.112:7778/"




