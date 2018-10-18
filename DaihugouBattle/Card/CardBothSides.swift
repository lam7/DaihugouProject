////
////  CardBothSides.swift
////  DaihugouBattle
////
////  Created by Main on 2017/11/24.
////  Copyright © 2017年 Main. All rights reserved.
////
//
//import Foundation
//import UIKit
//
///// 両面持ちのviewを持つクラス
//class CardBothSides: Card{
//    /// 両面view
//    private(set) var view: BothSidesView!
//    var frontImage: UIImage?
//    var backImage: UIImage?
//    
//    /// 引数をもとに両面持ちのviewを作成する
//    ///
//    /// - Parameters:
//    ///   - frontView: 前
//    //   - backView: 後ろ
//    //   - card: コピー対象のカード
//    init(frontView: UIView, backView: UIView, card: Card){
//        super.init(card: card)
//        self.view = BothSidesView(front: frontView, back: backView)
//    }
//    
//    
//    /// frontViewは"trumpBack.png, self.image, cardIndex.png"で構成される
//    /// backViewはUIColor.flatGrayで構成される
//    ///
//    /// - Parameter card: コピー対象のカード
//    override init(card: Card) {
//        super.init(card: card)
//        
//        let width = 60
//        let height = 80
//        
//        let backView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        let backImage       = DataRealm.get(imageNamed: "trumpBack.png")
//        self.backImage      = backImage
//        let backImageView   = UIImageView(image: backImage)
//        backImageView.frame = backView.bounds
//        backView.addSubview(backImageView)
//        
//        let frontView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        self.frontImage      = CardDecorateImage.decorateBackgroundAndIndex(card)
//        let frontImageView   = UIImageView(image: frontImage)
//        frontImageView.frame = frontView.bounds
//        frontView.addSubview(frontImageView)
//        
//        view = BothSidesView(front: frontView, back: backView)
//    }
//    
//    override func equal(_ to: Card) -> Bool {
//        if let rhs = to as? CardBothSides{
//            return super.equal(rhs) && self.view == rhs.view
//        }
//        return super.equal(to)
//    }
//    
//    override func update(_ id: Int, name: String, imageNamed: String, rarity: Rarity, index: Int, hp: Int, atk: Int, skill: Skill) {
//        super.update(id, name: name, imageNamed: imageNamed, rarity: rarity, index: index, hp: hp, atk: atk, skill: skill)
//        let frame = view.frame
//        let width = frame.width
//        let height = frame.height
//        let isBack = view.isBack
//        let backView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        let backImage       = DataRealm.get(imageNamed: "trumpBack.png")
//        self.backImage      = backImage
//        let backImageView   = UIImageView(image: backImage)
//        backImageView.frame = backView.bounds
//        backView.addSubview(backImageView)
//        
//        let frontView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        let background       = DataRealm.get(imageNamed: "cardBack.png")
//        let index            = DataRealm.get(imageNamed: "cardIndex\(self.index).png")
//        let frontImage       = UIImage.compose([background, self.image, index])
//        self.frontImage      = frontImage
//        let frontImageView   = UIImageView(image: frontImage)
//        frontImageView.frame = frontView.bounds
//        frontView.addSubview(frontImageView)
//        
//        view = BothSidesView(front: frontView, back: backView)
//        view.frame = frame
//        view.flip(0, isFront: !isBack)
//    }
//    
//}
