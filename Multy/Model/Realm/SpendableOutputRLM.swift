//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class SpendableOutputRLM: Object {

    @objc dynamic var transactionID = String()
    @objc dynamic var transactionOutAmount = NSNumber(value: 0)  // UInt 32
    @objc dynamic var transactionOutID = NSNumber(value: 0)      // UInt32
    @objc dynamic var transactionOutScript = String()
    @objc dynamic var addressID = NSNumber(value: 0)             // UInt32
    @objc dynamic var transactionStatus = NSNumber(value: 0)
    
    public class func initWithArray(spendableArray: NSArray, addressID: NSNumber) -> List<SpendableOutputRLM> {
        let outputs = List<SpendableOutputRLM>()
        
        for outputInfo in spendableArray {
            let output = SpendableOutputRLM.initWithInfo(addressInfo: outputInfo as! NSDictionary)
//            output.addressID = addressID
            outputs.append(output)
        }
        
        return outputs
    }
    
    public class func initWithInfo(addressInfo: NSDictionary) -> SpendableOutputRLM {
     
        let spendable = SpendableOutputRLM()
        
        if let txid = addressInfo["txid"]  {
            spendable.transactionID = txid as! String
        }
        
        if let txoutid = addressInfo["txoutid"]  {
            spendable.transactionOutID = NSNumber(value: txoutid as! UInt32)
        }
        
        if let transactionOutAmount = addressInfo["txoutamount"]  {
            spendable.transactionOutAmount = NSNumber(value: transactionOutAmount as! UInt32)
        }
        
        if let txoutscript = addressInfo["txoutscript"]  {
            spendable.transactionOutScript = txoutscript as! String
        }
        
        if let txStatus = addressInfo["txstatus"]  {
            spendable.transactionStatus = txStatus as! NSNumber
        }
        
        if let txAddressIndex = addressInfo["addressindex"]  {
            spendable.addressID = txAddressIndex as! NSNumber
        }
     
        return spendable
    }
        
}
