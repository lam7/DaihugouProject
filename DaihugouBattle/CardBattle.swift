//
//  CardBattle.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/02.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SpriteKit
import AudioToolbox
import UIKit

extension SystemSoundID{
    private static var id: SystemSoundID = 0
    static var ID: SystemSoundID{
        get{
            self.id += 1
            return self.id - 1
        }
    }
}

/// -TODO: SEやアニメーションなどを追加する
class CardBattle: CardBothSides{
}
