//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

//              new screen  1

let screenFirstLaunch        = "Screen_First_Launch"           // event name
let createFirstWalletTap     = "Button_Create_First_Wallet"    // event params
let restoreMultyTap          = "Button_Restore_Multy"

//              new screen  2

let screenCreateWallet       = "Screen_Create_Wallet"
let createWalletTap          = "Button_Create_Wallet"
let chainIdTap               = "Button_Chain_Id"
let fiatIdTap                = "Button_Fiat_Id"
//let   chainID
let cancelTap                = "Button_Cancel"                 //cancel or back

//              new screen  3

let screenViewPhrase         = "Screen_View_Phrase"
let closeTap                 = "Button_Close"                  //cancel or back
let repeatTap                = "Button_Repeat_Seed"

//              new screen  4

let screenRestoreSeed        = "Screen_Restore_Seed"
//let cancelTap               = "Button_Cancel"               //cancel or back

//              new screen  5

let screenSuccessRestore     = "Screen_Success_Restore_Seed"
//let cancelTap               = "Button_Cancel"               //cancel or back
let greatTap                 = "Button_Great"
let seedBackuped             = "Seed_Backuped"

//              new screen  6

let screenFailRestore        = "Screen_Fail_Restore_Seed"
//let cancelTap               = "Button_Cancel"               //cancel or back
let tryAgainTap              = "Button_Try_Again"
let seedBackupFailed         = "Seed_Backup_Failed"

//              new screen  7

let screenMain               = "Screen_Main"
//let closeTap                = "Button_Close"                  //cancel or back
let tabMainTap               = "Tab_Main"
let tabActivityTap           = "Tab_Activity"
let tabContactsTap           = "Tab_Contacts"
let tabSettingsTap           = "Tab_Settings"
let fastOperationsTap        = "Button_Fast_Operations"
//let createWalletTap          = "Button_Create_Wallet"
let logoTap                  = "Button_Logo"
let pullWallets              = "Pull_Wallets"
let walletOpenWithChainTap   = "Button_Wallet_Open-"//+chainID
let backupSeedTap            = "Button_Backup_Seed"

//              new screen  8

let screenActivity           = "Screen_Activity"
//let closeTap                = "Button_Close"                  //cancel or back

//              new screen  9

let screenContacts           = "Screen_Contacts"
//let closeTap                = "Button_Close"                  //cancel or back

//              new screen  10

let screenFastOperation      = "Screen_Fast_Operations"
//let closeTap                = "Button_Close"                  //cancel or back
let sendTap                  = "Button_Send"
let receiveTap               = "Button_Receive"
let nfcTap                   = "Button_NFC"
let scanTap                  = "Button_Scan"
//let scanGotPermossion        = "Button_Scan_Got_Permission"
//let scanDeniedPermission     = "Button_Scan_Denied_Permission"

//              new screen  11

let screenQR                 = "Screen_QR"
let scanGotPermossion       = "Button_Scan Got Permission"            // i think this events need to Send_from this screen
let scanDeniedPermission    = "Button_Scan Denied Permission"
//let closeTap                = "Button_Close"                  //cancel or back

//              new screen  12

let screenWalletWithChain    = "Screen_Wallet_"//+chainID
let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let settingsWithChainTap     = "Button_Settings_"//+chainID
let cryptoAmountWithChainTap = "Button_Crypto_"//+chainID
let fiatAmountWithChainTap   = "Button_Fiat_"//+chainID
let addressWithChainTap      = "Button_Address_"//+chainID
let shareWithChainTap        = "Button_Share_"//+chainID
let shareToAppWithChainTap   = "Shared_with_"//+chainID +AppName
let allAddressesWithChainTap = "Button_All_Addresses_"//+chainID
let sendWithChainTap         = "Button_Send_"//+chainID
let receiveWithChainTap      = "Button_Receive_"//+chainID
let exchangeWithChainTap     = "Button_Exchange_"//+chainID
let pullWalletWithChain      = "Pull_Wallet_"//+chainID
let transactionWithChainTap  = "Button_Transaction_"//+chainID
//let backupSeedTap            = "Button_Backup Seed"

//              new screen  13

let screenWalletAddressWithChain = "Scree_Wallet_Address_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
//let addressWithChainTap      = "Button_Address_"//+chainID

//              new screen  14

let screenTransactionWithChain = "Screen_Transaction_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let viewInBlockchainWithTxStatus = "Button_View_"//+chainID  +txStatus

//              new screen  15

let screenWalletSettingsWithChain = "Screen_Wallet_Settings_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let renameWithChainTap          = "Button_Rename_"//+chainID
let saveWithChainTap            = "Button_Save_"//+chainID
let fiatWithChainTap            = "Button_Fiat_"//+chainID
let showKeyWithChainTap         = "Button_Show_Key_"//+chainID
let deleteWithChainTap          = "Button_Delete_"//+chainID
let walletDeletedWithChain      = "Wallet_Deleted_"//+chainID
let walletDeleteCancelWithChain = "Wallet_Deleted_Canceled"//+chainID

//              new screen  16

let screenNoInternet            = "Screen_No_Internet"
//let closeTap                = "Button_Close"                  //cancel or back
let checkTap                    = "Button_Check"

//              new screen  17

let screenSendTo                = "Screen_Send_From"
//let closeTap                = "Button_Close"                  //cancel or back
//let addressBookTap              = "Button_Address_Book"
//let wirelessScanTap             = "Button_Wireless Scan"
let scanQrTap                   = "Button_Scan_Qr"

//              new screen  18

let screenSendFrom                = "Screen_Send_From"
//let closeTap                = "Button_Close"                  //cancel or back
let walletWithChainTap          = "Button_Wallet_"//+chainID

//              new screen  19

let screenTransactionFeeWithChain  = "Screen_Transaction_Fee_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let veryFastTap                 = "Button_Very_Fast"
let fastTap                     = "Button_Fast"
let mediumTap                   = "Button_Medium"
let slowTap                     = "Button_Slow"
let verySlowTap                 = "Button_Very_Slow"
let customTap                   = "Button_Custom"
let donationEnableTap           = "Button_Donation_Enabled"
let donationDisabledTap         = "Button_Donation_Disabled"
let customFeeSetuped            = "Button_Custom_Fee_Setuped"
let customFeeCanceled           = "Button_Custom_Fee_Canceled"
let donationON                  = "Donation"
let donationChanged             = "Button_Donation_Changed"

//              new screen  20

let screenSendAmountWithChain   = "Screen_Send_Amount_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let fiatTap                     = "Button_Fiat"
let cryptoTap                   = "Button_Crypto"
let switchTap                   = "Button_Switch"
let payForCommissionEnabled     = "Button_Pay_For_Commission_Enabled"
let payForCommissionDisabled    = "Button_Pay_For_Commission_Disabled"
let payMaxTap                   = "Button_Pay_Max"
let transactionErr              = "Error_Transaction_Sign"

//              new screen  21

let screenSendSummaryWithChain  = "Screen_Send_Summary_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let addNoteTap                  = "Button_Add_Note"
let transactionErrorFromServer  = "Error_Sending_Trasaction_From_Api"

//              new screen  22

let screenSendSuccessWithChain  = "Screen_Send_Success"//+chainID
//let closeTap                 = "Button_Close"                  //cancel or back

//              new screen  23

let screenReceive              = "Screen_Receive"
//let closeTap                 = "Button_Close"                  //cancel or back
//let walletWithChainTap          = "Button_Wallet_"//+chainID

//              new screen  24

let screenReceiveSummaryWithChain = "Screen_Receive_Summary_"//+chainID
//let closeWithChainTap        = "Button_Close_"//+chainID         //cancel or back
let qrTap                       = "Button_QR"
let addressTap                  = "Button_Address"
let requestSumTap               = "Button_Request_Sum"
let changeWalletTap             = "Button_Change_Wallet"
let addressBookTap              = "Button_Address_Book"
let wirelessScanTap             = "Button_Wireless Scan"
let moreOptionsTap              = "Button_More_Options"
//let shareToAppWithChainTap   = "Shared with "//+chainID +AppName
let moneyReceived               = "Money_Received"

//              new screen  25

let screenSettings              = "Screen_Settings"
//let closeTap                 = "Button_Close"                  //cancel or back
let pushesEnabled               = "Button_Pushes_Enabled"
let pushesDisabled              = "Button_Pushes_Disabled"
let securitySettingsTap         = "Button_Security_Settings"

//              new screen  26

let screenSecuritySettings      = "Screen_Security_Settings"
//let closeTap                 = "Button_Close"                  //cancel or back
let viewSeedTap                 = "Button_View_Seed"
let resetTap                    = "Button_Reset"
let resetComplete               = "Reset_Complete"
let resetDeclined               = "Reset_Declined"
let blockSettingsTap            = "Button_Block Settings"

//              new screen  27

let screenBlockSettings         = "Screen_Block_Settings"
//let closeTap                 = "Button_Close"                  //cancel or back
let pinEnabledTap               = "Button_PIN_Enabled"
let pinDisableTap               = "Button_PIN_Disabled"
let pinSetuped                  = "PIN_Setuped"


let pushReceivedWithPushId      = "Push_Received_"//+pushID
let openAppByPushWithPushId     = "Open_App_By_Push "//+pushID


//Donation section
let screeenDonationAlert        = "Screen_Donation_Alert"
let screeenDonationAlertWith_   = "Screen_Donation_Alert_"//+FEATURE_ID
let buttonClose                 = "Button_Close_"//+FEATURE_ID
let buttonDonate                = "Button_Donate_"//+FEATURE_ID

let screenSendDonation          = "Screen_Send_Donation"
let screenSendDonationwith_     = "Screen_Send_Donation_"//+FEATURE_ID
let buttonSendDonate            = "Button_Send_Donate_"//+FEATURE_ID

let screenDonationSuccess       = "Screen_Donation_Success"
let screenDonationSuccessWith_  = "Screen_Donation_Success_"//+FEATURE_ID

//featues code
let donationWithTransaction     = 20000

let donationForBTCLighting      = 20100
let donationForETH              = 20101
let donationForGOLOS            = 20102
let donationForSTEEMIT          = 20103
let donationForBTS              = 20104
let donationForBCH              = 20105
let donationForLTC              = 20106
let donationForDSH              = 20107
let donationForETC              = 20108
let donationForERC20Token       = 20109
let donationForEUR              = 20110
let donationForEstimationETH    = 20111

let donationForActivitySC       = 20200
let donationForContactSC        = 20201
let donationForPortfolioSC      = 20202
let donationForChartsSC         = 20203

let donationForImportWallet     = 20300
let donationForExchangeFUNC     = 20301
let donationForWirelessScanFUNC = 20302

let donationForBinanceStock     = 20400
let donationForOKExStock        = 20401
let donationForHuobiStock       = 20402
let donationForUpbitStock       = 20403
let donationForBitfinexStock    = 20404
let donationForBittrexStock     = 20405
let donationForBithumbStock     = 20406
let donationForGDAXStock        = 20407
let donationForKrakenStock      = 20408
let donationForHitBTCStock      = 20409
