//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

extension Dictionary {
    
    static func createTopIndexes(indexesDict: Array<Dictionary<String, UInt32>>) -> Dictionary<UInt32, UInt32> {
        var indexes = Dictionary<UInt32, UInt32>()
        
        for index in indexesDict {
            indexes[index["currencyid"]!] = index["topindex"]!
        }
        
        return indexes
    }
}
