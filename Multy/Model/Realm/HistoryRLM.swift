//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import RealmSwift

class HistoryRLM: Object {
    
    @objc dynamic var addresses = String() {
        didSet {
            addressesArray = addresses.components(separatedBy: " ")
        }
    }
    @objc dynamic var blockHeight = Int()
    @objc dynamic var blockTime = Date()
    @objc dynamic var fiatCourseExchange = Double()
    @objc dynamic var txFee: NSNumber = 0
    @objc dynamic var txHash = String()
    @objc dynamic var txId = String()
    var txInputs = List<TxHistoryRLM>()
    @objc dynamic var txOutAmount: NSNumber = 0
    @objc dynamic var txOutAmountString = String()
    
    @objc dynamic var gasLimit: NSNumber = 0
    @objc dynamic var gasPrice: NSNumber = 0
    
    @objc dynamic var txOutId = Int()
    var txOutputs = List<TxHistoryRLM>()
    @objc dynamic var txOutScript = String()
    @objc dynamic var txStatus = NSNumber(value: 0)
    @objc dynamic var walletIndex = NSNumber(value: 0)
    
    @objc dynamic var mempoolTime = Date()
    @objc dynamic var confirmations = Int()
    
    @objc dynamic var addressesArray = [String]()
    var exchangeRates = List<StockExchangeRateRLM>()
    var walletInput = List<UserWalletRLM>()
    var walletOutput = List<UserWalletRLM>()
    
    override static func ignoredProperties() -> [String] {
        return ["addressesArray"]
    }
    
    // FIXME: delete txOutAmount, only string values
    func txAmount(for blockchain: Blockchain) -> String {
        switch blockchain {
        case BLOCKCHAIN_BITCOIN:
            return txOutAmount.doubleValue.fixedFraction(digits: 8)
        case BLOCKCHAIN_ETHEREUM:
            return txOutAmountString.appendDelimeter(at: 18)
        default:
            return ""
        }
    }
    
    public class func initWithArray(historyArr: NSArray) -> List<HistoryRLM> {
        let history = List<HistoryRLM>()
        
        for obj in historyArr {
            let histElement = HistoryRLM.initWithInfo(historyDict: obj as! NSDictionary)
            history.append(histElement)
        }
        
        return history
    }
    
    public class func initWithInfo(historyDict: NSDictionary) -> HistoryRLM {
        let hist = HistoryRLM()
        
//        if let address = txHistory["address"] {
//            txHist.address = address as! String
//        }
        if let addresses = historyDict["addresses"] {
            hist.addresses = (addresses as! NSArray).componentsJoined(by: " ")
        }
        
        if let blockheight = historyDict["blockheight"] {
            hist.blockHeight = blockheight as! Int
        }
        
        if let confirmations = historyDict["confirmations"] as? Int {
            hist.confirmations = confirmations
        }
        
        if let blocktime = historyDict["blocktime"] {
            hist.blockTime = NSDate(timeIntervalSince1970: (blocktime as! Double)) as Date
        }
        
        if hist.blockHeight == -1 {
            hist.blockTime = Date()
        }
        
        if let mempoolTime = historyDict["mempooltime"] {
            hist.mempoolTime = NSDate(timeIntervalSince1970: (mempoolTime as! Double)) as Date
        }
        
        if let txfee = historyDict["txfee"] {
            hist.txFee = txfee as! NSNumber
        }
        
        if let txhash = historyDict["txhash"] {
            hist.txHash = txhash as! String
        }
        
        if let txid = historyDict["txid"] {
            hist.txId = txid as! String
        }
        
        if let txinputs = historyDict["txinputs"] {
            hist.txInputs = TxHistoryRLM.initWithArray(txHistoryArr: txinputs as! NSArray)
        }
        
        if let rates = historyDict["stockexchangerate"] as? NSArray {
            hist.exchangeRates = StockExchangeRateRLM.initWithArray(stockArray: rates)
            // BTC and ETH // FIXME: fix it later
            if hist.exchangeRates.count > 0 {
                if hist.txInputs.count > 0 {
                    hist.fiatCourseExchange = hist.exchangeRates.first!.btc2usd.doubleValue
                } else {
                    hist.fiatCourseExchange = hist.exchangeRates.first!.eth2usd.doubleValue
                }
            }
        }

        if let txoutamount = historyDict["txoutamount"] as? NSNumber {
            hist.txOutAmount = txoutamount
        } else if let txOutAmountString = historyDict["txoutamount"] as? String {
            hist.txOutAmountString = txOutAmountString
        }
        
        if let gasPrice = historyDict["gasprice"] as? NSNumber {
            hist.gasPrice = gasPrice
        }
        
        if let gasLimit = historyDict["gaslimit"] as? NSNumber {
            hist.gasLimit = gasLimit
        }
        
        if let txoutid = historyDict["txoutid"] {
            hist.txOutId = txoutid as! Int
        }
        
        if let txoutputs = historyDict["txoutputs"] {
            hist.txOutputs = TxHistoryRLM.initWithArray(txHistoryArr: txoutputs as! NSArray)
        }

        if let txoutscript = historyDict["txoutscript"] {
            hist.txOutScript = txoutscript as! String
        }
        
        if let txstatus = historyDict["txstatus"] {
            hist.txStatus = txstatus as! NSNumber
        }
        
        //FIXME: add more parameters
        if let walletindex = historyDict["walletindex"] {
            hist.walletIndex = walletindex as! NSNumber
        }
        
        if let walletsinput = historyDict["walletsinput"] as? NSArray {
            hist.walletInput = UserWalletRLM.initWithArray(walletsInfo: walletsinput)
        }
        
        if let walletOutput = historyDict["walletsoutput"] as? NSArray {
            hist.walletOutput = UserWalletRLM.initWithArray(walletsInfo: walletOutput)
        }
        
        //ETH part
        if let fromAddress = historyDict["from"] as? String {
            hist.addressesArray.append(fromAddress)
        }
        
        if let destinationAddress = historyDict["to"] as? String {
            hist.addressesArray.append(destinationAddress)
        }
        
        return hist
    }
    
    override class func primaryKey() -> String? {
        return "txId"
    }
    
    func isIncoming() -> Bool {
        return self.txStatus.intValue == TxStatus.MempoolIncoming.rawValue || self.txStatus.intValue == TxStatus.BlockIncoming.rawValue || self.txStatus.intValue == TxStatus.BlockConfirmedIncoming.rawValue
    }
    
    func getDonationTxOutput(address: String) -> TxHistoryRLM? {
        for output in self.txOutputs {
            if output.address == address {
                return output
            }
        }
        
        return nil
    }
}
