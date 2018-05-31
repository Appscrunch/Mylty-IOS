//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

protocol ReceiveSumTransferProtocol: class {
    func transferSum(cryptoAmount: String, cryptoCurrency: String, fiatAmount: String, fiatName: String)
}
