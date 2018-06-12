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
    let userID : String
    let userCode : String
    let sendAmount : String
    let currencyID : Int
    let networkID : Int
    var satisfied = false
    
    var requestImageName : String {
        get {
            let imageNumber = sendAddress.convertToImageIndex
            
            return "wirelessRequestImage_" + "\(imageNumber)"
            
//            if let userCodeInt = UInt32(userCode, radix: 16) {
//                let imageNumber = Int(userCodeInt)%wirelessRequestImagesAmount
//                return "wirelessRequestImage_" + String(imageNumber)
//            } else {
//                return ""
//            }
        }
    }
    
    init(sendAddress : String, userCode : String, currencyID : Int, sendAmount : String, networkID : Int, userID : String) {
        self.sendAddress = sendAddress
        self.currencyID = currencyID
        self.sendAmount = sendAmount
        self.networkID = networkID
        self.userCode = userCode
        self.userID = userID
    }
}
