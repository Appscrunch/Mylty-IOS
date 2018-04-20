//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation
import RealmSwift

class AddressRLM: Object {
    @objc dynamic var addressID = NSNumber(value: 0)    //UInt32
    @objc dynamic var currencyID = NSNumber(value: 0)   //UInt32
//    @objc dynamic var walletID = NSNumber(value: 0)     //UInt32
    
    @objc dynamic var address = String()                //Double
    @objc dynamic var amount = NSNumber(value: 0)       //UInt32
    @objc dynamic var amountString = String()           //String
    @objc dynamic var lastActionDate = Date()
    
    var spendableOutput = List<SpendableOutputRLM>()
    
    public class func initWithArray(addressesInfo: NSArray) -> List<AddressRLM> {
        let addresses = List<AddressRLM>()
        
        for addressInfo in addressesInfo {
            let wallet = AddressRLM.initWithInfo(addressInfo: addressInfo as! NSDictionary)
            addresses.append(wallet)
        }
        
        return addresses
    }
    
    public class func initWithInfo(addressInfo: NSDictionary) -> AddressRLM {
        let addressRLM = AddressRLM()
        
        if let addressID = addressInfo["addressindex"]  {
            addressRLM.addressID = NSNumber(value: addressID as! UInt32)
        }
        
//        if let currencyID = addressInfo["currencyID"]  {
//            addressRLM.currencyID = NSNumber(value: currencyID as! UInt32)
//        }
        
//        if let walletID = addressInfo["walletID"]  {
//            addressRLM.walletID = NSNumber(value: walletID as! UInt32)
//        }
        
        if let addressString = addressInfo["address"] {
            addressRLM.address = addressString as! String
        }
        
        if let date = addressInfo["lastActionTime"] {
            addressRLM.lastActionDate = NSDate(timeIntervalSince1970: (date as! Double)) as Date
        }
        
        if let amount = addressInfo["amount"] {
            if let amount = amount as? NSNumber {
                addressRLM.amount = amount
            } else if let amountString = amount as? String {
                addressRLM.amountString = amountString
            }
        }
        
        if let spendableOutputs = addressInfo["spendableoutputs"] {
            if !(spendableOutputs is NSNull) {
                addressRLM.spendableOutput = SpendableOutputRLM.initWithArray(spendableArray: spendableOutputs as! NSArray, addressID: addressRLM.addressID)
            }
        }
        
        return addressRLM
    }
}
