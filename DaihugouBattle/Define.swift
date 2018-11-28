//
//  DefineServer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/02/01.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation

let ErrorDomain = "daipro"

class Plist{
    /// Info.plistのBuildleVersionを返す
    static var version: Int{
        let v =  Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return v.i!
    }
}

/// 自作のエラーはこのクラスにExtensionされる
class Errors{
    static let ErrorDomain = "com.lam.daipro"
    private(set) static var _code = 0
    static var code: Int{
        get{
            _code += 1
            return _code
        }
    }
}

/// デッキ枚数
let StandartDeckCardsNum: Int = 40
/// 最大デッキ所持数
let MaxPossessionDecksNum: Int = 18
