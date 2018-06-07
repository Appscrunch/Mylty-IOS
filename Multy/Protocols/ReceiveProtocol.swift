//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

@objc protocol ReceiveSumTransferProtocol: class {
    @objc optional func transferSum(cryptoAmount: String, cryptoCurrency: String, fiatAmount: String, fiatName: String)
    @objc optional func fundsReceived(_ amount: String,_ address: String)
}
