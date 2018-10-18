//
//  CardBothSidesLayer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/18.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
//
///// 両面持ちのviewを持つクラス
//class CardBothSidesLayer: Card{
//    /// 両面view
//    private(set) var view: BothSidesLayer!
//
//
//    /// 引数をもとに両面持ちのviewを作成する
//    ///
//    /// - Parameters:
//    ///   - frontView: 前
//    ///   - backView: 後ろ
//    ///   - card: コピー対象のカード
//    //    init(frontView: UIView, backView: UIView, card: Card){
//    //        super.init(card: card)
//    //        self.view = BothSidesView(front: frontView, back: backView)
//    //    }
//
//
//    /// frontViewは"trumpBack.png, self.image, cardIndex.png"で構成される
//    /// backViewはUIColor.flatGrayで構成される
//    ///
//    /// - Parameter card: コピー対象のカード
//    override init(card: Card) {
//        let date = Date()
//        super.init(card: card)
//
//        let width = 60
//        let height = 80
//        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
//
//        let backImageLayer = CALayer()
//        backImageLayer.contents = DataRealm.get(imageNamed: "trumpBack.png")?.cgImage
//        backImageLayer.frame = bounds
////        var elapsed = Date().timeIntervalSince(date)
////        print("CardBothSidesLayer back \(elapsed)")
//
//
//        let frontImageLayer = CALayer()
//        frontImageLayer.frame = bounds
//        let original = card.image
//        let background = DataRealm.get(imageNamed: "cardBack.png")
//        let index = DataRealm.get(imageNamed: "cardIndex\(card.index).png")
//        let backLayer = CALayer()
//        let originalLayer = CALayer()
//        let indexLayer = CALayer()
//
//        backLayer.contents = background?.cgImage
//        originalLayer.contents = original?.cgImage
//        indexLayer.contents = index?.cgImage
//        frontImageLayer.addSublayer(backLayer)
//        frontImageLayer.addSublayer(originalLayer)
//        frontImageLayer.addSublayer(indexLayer)
//
//        frontImageLayer.frame = bounds
//        backLayer.frame = bounds
//        originalLayer.frame = bounds
//        indexLayer.frame = bounds
//
////        elapsed = Date().timeIntervalSince(date)
////        print("CardBothSidesLayer fron \(elapsed)")
//
//        view = BothSidesLayer(frame: bounds)
//
//        view.front.addSublayer(frontImageLayer)
//        view.back.addSublayer(backImageLayer)
////        elapsed = Date().timeIntervalSince(date)
////        print("CardBothSidesLayer init \(elapsed)")
//    }
//
//    init(card: Card, view: BothSidesLayer){
//        super.init(card: card)
//        self.view = view
//    }
//
//    override func equal(_ to: Card) -> Bool {
//        if let rhs = to as? CardBothSides{
//            return super.equal(rhs) && self.view == rhs.view
//        }
//        return super.equal(to)
//    }

//    override func update(_ id: Int, name: String, imageNamed: String, rarity: Rarity, index: Int, hp: Int, atk: Int, skill: Skill) {
//        super.update(id, name: name, imageNamed: imageNamed, rarity: rarity, index: index, hp: hp, atk: atk, skill: skill)
//        let frame = view.frame
//        let width = frame.width
//        let height = frame.height
//        let isBack = view.isBack
//        let backView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        let backImage       = DataRealm.get(imageNamed: "trumpBack.png")
//        backImageView   = UIImageView(image: backImage)
//        backImageView.frame = backView.bounds
//        backView.addSubview(backImageView)
//
//        let frontView        = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        let background       = DataRealm.get(imageNamed: "cardBack.png")
//        let index            = DataRealm.get(imageNamed: "cardIndex\(self.index).png")
//        let frontImage       = UIImage.compose([background, self.image, index])
//        frontImageView   = UIImageView(image: frontImage)
//        frontImageView.frame = frontView.bounds
//        frontView.addSubview(frontImageView)
//
//        view = BothSidesView(frame: frame)
//        view.frontView = frontView
//        view.backView = backView
//        view.flip(0, isFront: !isBack)
//    }
//
//}

