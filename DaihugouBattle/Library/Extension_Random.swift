//
//  Extension_Random.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/12.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit


extension Bool{
    static var random: Bool{
            return arc4random() % 2 == 0
    }
}

extension Int{
    ///  Return random natural number From 0 or more and less than self
    public var random: Int{
        return Int(arc4random_uniform(UInt32(self)))
    }
    
    /// Return random sign value.
    /// Positive and negative is selected randomly.
    public var randomSign: Int{
        let sign = arc4random_uniform(2) == 0
        return sign ? self : self * -1
    }
}

extension Float{
    ///  Return random float number From 0 or more and less than self
    public var random: Float{
        return Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max) * self
    }
    
    /// Return random sign value.
    /// Positive and negative is selected randomly.
    public var randomSign: Float{
        let sign = arc4random_uniform(2) == 0
        return sign ? self : self * -1
    }
    
//    public func random(_ range: Range<Float>...)-> Float{
//        
//    }
}

extension CGFloat{
    ///  Return random natural number From 0 or more and less than self
    public var random: CGFloat{
        let max = UInt32.max
        return CGFloat(arc4random_uniform(max)) / CGFloat(max) * self
    }
    
    /// Return random sign value.
    /// Positive and negative is selected randomly.
    public var randomSign: CGFloat{
        let sign = arc4random_uniform(2) == 0
        return sign ? self : self * -1
    }
}


extension Double{
    ///  Return random natural number From 0 or more and less than self
    public var random: Double{
        return Double(arc4random()) / Double.greatestFiniteMagnitude * self
    }
    
    /// Return random sign value.
    /// Positive and negative is selected randomly.
    public var randomSign: Double{
        let sign = arc4random_uniform(2) == 0
        return sign ? self : self * -1
    }
}

extension Array{
    public var random: Element{
        let rand = count.random
        return self[rand]
    }
}

/// 指定の確率値で起きる事象の真か偽を返す
///
/// - Parameters:
///     - v: 確率値
/// - Returns: v％で起きる確率の真か偽を返す

public func probability(_ v: Double)-> Bool{
    
    if v <= 0{
        return false
    }
    if v >= 1{
        return true
    }
    let rand: Double = Double(arc4random()) / Double.greatestFiniteMagnitude
    if rand < v{
        return false
    }
    return true
}

/// 指定の確率値で起きる事象の真か偽を返す
///
/// - Parameters:
///   - nume: 分母
///   - deno: 分子
/// - Returns: (分子/分母)％で起きる確率の真か偽を返す
public func probability(nume: UInt32, deno: UInt32)-> Bool{
    if nume <= deno{
        return true
    }
    let rand = arc4random_uniform(nume)
    return deno >= rand
}




