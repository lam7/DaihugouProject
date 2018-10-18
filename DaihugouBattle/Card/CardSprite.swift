//
//  CardSprite.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/29.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SpriteKit
import Chameleon


/// カードにSKSpriteNodeを付けたクラス
class CardSprite: Card{
    private(set) var sprite: SKSpriteNode?


    /// 画像は自身のimage + cardBack.png + cardIndex.pngで構成されるCard
    ///
    /// - Parameter card: このカード情報をもとにカードを作る
    override init(card: Card) {
        super.init(card: card)
        let image: UIImage = DataRealm.get(imageNamed: self.imageNamed)!
        let backImage: UIImage = DataRealm.get(imageNamed: "cardBack.png")!
        let frontImage: UIImage = DataRealm.get(imageNamed: "cardIndex\(self.index).png")!
        let texture: SKTexture = SKTexture(image: UIImage.compose([backImage, image, frontImage]))
        self.sprite = SKSpriteNode(texture: texture)
    }

    override func equal(_ to: Card) -> Bool {
        if let rhs = to as? CardSprite{
            return super.equal(to) && self.sprite == rhs.sprite
        }
        return super.equal(to)
    }
}
