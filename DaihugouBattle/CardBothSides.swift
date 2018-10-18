//
//  CardBothSides.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit


/// 両面持ちのviewを持つクラス
class CardBothSides: Card{
    /// 両面view
    private(set) var view: BothSidesView!
    /// 前view
    private(set) weak var frontView: UIView!
    /// 後ろview
    private(set) weak var backView: UIView!
    
    
    /// 引数をもとに両面持ちのviewを作成する
    ///
    /// - Parameters:
    ///   - frontView: 前
    ///   - backView: 後ろ
    ///   - card: コピー対象のカード
    init(frontView: UIView, backView: UIView, card: Card){
        super.init(card: card)
        
        self.frontView = frontView
        self.backView = backView
        self.view = BothSidesView(front: frontView, back: backView)
    }
    
    
    /// frontViewは"trumpBack.png, self.image, cardIndex.png"で構成される
    /// backViewはUIColor.flatGrayで構成される
    ///
    /// - Parameter card: コピー対象のカード
    override init(card: Card) {
        super.init(card: card)
        
        let backView  = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        backView.image = ImageRealm.get(imageNamed: "trumpBack.png")
        self.backView = backView
        
        frontView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        let backgroundView = UIImageView(frame: frontView.bounds)
        backgroundView.image = ImageRealm.get(imageNamed: "cardBack.png")
        let indexView = UIImageView(frame: CGRect(x: 0, y: 0, width: frontView.frame.width, height: frontView.frame.height))
        indexView.image = ImageRealm.get(imageNamed: "cardIndex\(self.index).png")
        let chView = UIImageView(frame: CGRect(x: 0, y: 0, width: frontView.frame.width, height: frontView.frame.height))
        chView.image = card.image
        frontView.addSubview(backgroundView)
        frontView.addSubview(chView)
        frontView.addSubview(indexView)
        
        view = BothSidesView(front: frontView, back: backView)
        
    }
    
    override func equal(_ to: Card) -> Bool {
        if let rhs = to as? CardBothSides{
            return super.equal(rhs) && self.view == rhs.view
        }
        return super.equal(to)
    }

}
