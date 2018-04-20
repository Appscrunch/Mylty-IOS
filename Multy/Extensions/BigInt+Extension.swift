//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

extension _BigInt {
    var btcString: String {
        return self.toString().appendDelimeter(at: 8)
    }
    
    var ethString: String {
        return self.toString().appendDelimeter(at: 18)
    }
}
