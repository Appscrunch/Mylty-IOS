//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

protocol DonationProtocol: class {
    func donate(idOfInApp: String)
    func cancelDonation()
}
