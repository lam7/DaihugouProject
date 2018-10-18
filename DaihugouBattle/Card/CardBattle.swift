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
class CardBattle: Card{
    ///カード１枚１枚に与えられるUUID
    ///同じカードを複製しても、違うUUIDが与えられる
    private(set) var uuid: UUID
    
    ///カード情報をもとに、異なったuuidを持つカードを作成する。
    ///同じカードでも、このイニシャライザで作るものはuuidが異なる。
    required init(card: Card) {
        uuid = UUID.init()
        super.init(card: card)
    }
    
    override func equal(_ to: Card)-> Bool {
        guard let to = to as? CardBattle else{
            return false
        }
        return super.equal(to) && self.uuid == to.uuid
    }
    
    ///UUIDもコピーされた、全く同じカードを複製する
    override func copy(with zone: NSZone? = nil) -> Any {
        let card = CardBattle(card: self)
        card.uuid = self.uuid
        return card
    }
}

