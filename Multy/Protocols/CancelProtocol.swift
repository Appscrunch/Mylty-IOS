//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

@objc protocol CancelProtocol: class {
    func cancelAction()
    func presentNoInternet()
    @objc optional func donate50(idOfProduct: String)
}
