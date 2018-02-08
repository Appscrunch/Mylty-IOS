//
//  StockExchangeRates.swift
//  Multy
//
//  Created by MacBook on 24.01.2018.
//Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import Foundation
import RealmSwift

class StockExchangeRateRLM: Object {
    
    @objc dynamic var id = NSNumber(value: 1)   //
    @objc dynamic var name = String()
//    @objc dynamic var exchanges = Dictionary<String, Double>()
    @objc dynamic var btc2usd = NSNumber(value: 0) //Double//MARK: to be deleted
    @objc dynamic var date = Date()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    public class func initWithArray(stockArray: NSArray) -> List<StockExchangeRateRLM> {
        let rates = List<StockExchangeRateRLM>()
        
        for stock in stockArray {
            let rate = StockExchangeRateRLM.initWithInfo(stockInfo: stock as! NSDictionary)
            rates.append(rate)
        }
        
        return rates
    }
    
    public class func initWithInfo(stockInfo: NSDictionary) -> StockExchangeRateRLM {
        
        let stock = StockExchangeRateRLM()
        
        if let exchanges = stockInfo["exchanges"] as? NSDictionary  {
            if let btc2usd = exchanges["btc_usd"] as? NSNumber {
                stock.btc2usd = btc2usd
            }
            if let usd2btc = exchanges["usd_btc"] as? NSNumber {
                
            }
        }
        
        if let stockExchange = stockInfo["stock_exchange"] as? String {
            stock.name = stockExchange
        }
        
        if let date = stockInfo["timestamp"] as? Double  {
            stock.date = NSDate(timeIntervalSince1970: date) as Date
        }
        
        return stock
    }
}
