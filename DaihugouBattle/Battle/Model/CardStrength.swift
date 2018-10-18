//
//  StrengthOfIndex.swift
//  Daihugou
//
//  Created by Main on 2017/05/23.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

//let AbsolutelyUsedNumber = [1,2,3,4,5,6,7,8,9,10,11,12,13]
/// CardStrengthにいれる最低限必要な数字
let AbsolutelyUsedNumber = [1,2,3,4,5,6,7,8,9,10,0]


/// カードの強さを定義
enum CardStrength{
    case normal, revolution
    
    var strength: [Int]{
        switch self{
        case .normal:
            return [1,2,3,4,5,6,7,8,9,10,0]
        case .revolution:
            return [10,9,8,7,6,5,4,3,2,1,0]
        }
    }
    
    
    /// どちらカードの方が強いか比べる
    ///
    /// - Parameters:
    ///   - compare: 比べる方
    ///   - compared: 比べられる方
    /// - Returns: compareの方が強いかどうか
    func compare(_ compare: Int, _ compared: Int)-> Bool{
        guard let i1 = strength.index(of: compare),
            let i2 = strength.index(of: compared) else{
                print("CardStrength_compare")
                print("Not Contains \(compare) \(compared)")
                return false
        }
        return i1 > i2
    }
}
