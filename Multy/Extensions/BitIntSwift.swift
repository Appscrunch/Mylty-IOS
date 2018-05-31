//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Foundation

struct BigIntSwift {
    
    var value: String
    
    func multiply(by right: BigIntSwift) -> BigIntSwift {
        var leftCharacterArray = value.characters.reversed().map { Int(String($0))! }
        var rightCharacterArray = right.value.characters.reversed().map { Int(String($0))! }
        var result = [Int](repeating: 0, count: leftCharacterArray.count+rightCharacterArray.count)
        
        for leftIndex in 0..<leftCharacterArray.count {
            for rightIndex in 0..<rightCharacterArray.count {
                
                let resultIndex = leftIndex + rightIndex
                
                result[resultIndex] = leftCharacterArray[leftIndex] * rightCharacterArray[rightIndex] + (resultIndex >= result.count ? 0 : result[resultIndex])
                if result[resultIndex] > 9 {
                    result[resultIndex + 1] = (result[resultIndex] / 10) + (resultIndex+1 >= result.count ? 0 : result[resultIndex + 1])
                    result[resultIndex] -= (result[resultIndex] / 10) * 10
                }
                
            }
            
        }
        
        result = Array(result.reversed())
        return  BigIntSwift(value: result.map { String($0) }.joined(separator: ""))
    }
}

func * (left: BigIntSwift, right: BigIntSwift) -> BigIntSwift { return left.multiply(by: right) }
