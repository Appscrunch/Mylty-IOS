//
//  PaymentRequest.swift
//  Multy
//
//  Created by Artyom Alekseev on 16.05.2018.
//  Copyright © 2018 Idealnaya rabota. All rights reserved.
//

import UIKit

class PaymentRequest: NSObject {
    let sendAddress : String
    let sendAmount : Double
    let currencyID : NSNumber
    let color : UIColor // TODO: change to metamask image
    
    init(sendAddress : String, currencyID : NSNumber, sendAmount : Double, color : UIColor) {
        self.sendAddress = sendAddress
        self.currencyID = currencyID
        self.sendAmount = sendAmount
        self.color = color
    }
}
