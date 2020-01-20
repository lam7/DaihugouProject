//
//  DefineServer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/02/01.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

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
let MaxPossessionDecksNum: Int = 27
/// 表示受け取り済みアイテム最大値
let MaxReceivedGiftedItemsNum: Int = 20

var CharacterDetailViewFrame: CGRect{
    let bounds = UIScreen.main.bounds
    let width = bounds.width * 0.8
    let height = bounds.height * 0.9
    return CGRect(x: bounds.midX - width / 2, y: bounds.midY - height / 2, width: width, height: height)
}
