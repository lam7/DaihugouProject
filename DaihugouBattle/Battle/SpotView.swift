//
//  SpotView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/10.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

/*
 Tag
 100 SpotView
 101 OwnerAtkLabel
 102 EnemyAtkLabel
 */
class SpotView: UIView, SpotDelegate, CAAnimationDelegate{
    var spot: Spot{
        return battleMaster.battleField.spot
    }
    
    var battleMaster: BattleMaster!
    private var animComp: CAAnimationCompletion<CAAnimationDelegate>!
    
    var ownerCardViews: [CardView]!
    var enemyCardViews: [CardView]!
    
    /// 出したカードを表示するビュー
    lazy var spotView: UIView = self.viewWithTag(100)!
    
    lazy var spotButton: UIButton = self.viewWithTag(103) as! UIButton
    
    var spotCollectionView: SpotCollectionView!
    
    /// カードを出すアニメーションにかかる時間
    private let putDownDuration: TimeInterval = 0.3
    
    
    /// カードを置く位置をランダムに返す
    /// -TODO: キチンと実装する
    private var randomPoint: CGPoint{
        return CGPoint(x: self.center.x + 35.cf.random.randomSign, y: self.center.y + 25.cf.random.randomSign)
    }
    
    
    /// カードの傾きをランダムに返す
    private var randomRad: CGFloat{
        return 180.random.cf / 180.cf * CGFloat.pi
    }
    
    /// カードの大きさを返す
    private var cardSize: CGSize{
        let width = self.frame.width / 9
        let height = width * 4 / 3
        return CGSize(width: width, height: height)
    }
    
    /// カードの重なり量を返す
    private var cardOverlap: CGFloat{
        let size = cardSize
        return size.width / 3
    }
    
    var asyncBlock: ControllAsyncBlock{
        return BattleViewController.asyncBlock
    }
    
    /// パラメータをセットする。初期化時に必ず呼ぶ
    func set(battleMaster: BattleMaster){
        self.battleMaster = battleMaster
        spot.delegate = self
        animComp = CAAnimationCompletion(parent: self)
    }
    
    
    /// カードを置く位置を決める
    ///
    /// - Parameter cards: 場に出すカード
    /// - Returns: カードのそれぞれの位置
    private func points(_ cards: [CardView])-> [CGPoint]{
        let randomPoint = self.randomPoint
        let cardSize = cards[0].frame.size
        let midX = (cardSize.width * cards.count) / 2
        var result: [CGPoint] = []
        for i in 0..<cards.count{
            if i < cards.count / 2{
                var p = randomPoint.x - (cards.count / 2).cf * cardSize.width + i.cf * cardSize.width
                p -= i * cardOverlap
                result.append(CGPoint(x: p, y: randomPoint.y))
            }else{
                var p = randomPoint.x + (i - cards.count / 2).cf * cardSize.width
                p -= i * cardOverlap
                result.append(CGPoint(x: p, y: randomPoint.y))
            }
        }

        return result
        //        let stackView = UIStackView(frame: CGRect(x: randomPoint.x - midX , y: randomPoint.y,
        //                                                  width: cardSize.width * cards.count, height: cardSize.height))
        //        cards.forEach{ stackView.addSubview($0.view) }
        //        stackView.spacing = -cardOverlap
        //        let result = stackView.subviews.map{ $0.center }
    }
    
    func didPutDown(_ cards: [Card], isOwner: Bool) {
        asyncBlock.add{
            [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.spotCollectionView.insertData((cards: cards, isOwnerTurn: isOwner))
            var cardViews: [CardView] = []
            if isOwner{
               cardViews = (cards as! [CardBattle]).map({ self.cardView($0) })
            }else{
                let views = self.cardViewsInEnemyHand()
                cardViews = views[0..<cards.count].map{ $0 }
                for i in 0..<cards.count{
                    cardViews[i].card = cards[i]
                }
                if cardViews.isEmpty{
                    
                }
            }
            
            //カードを出す位置までアニメーションさせる
            let points = self.points(cardViews)
            for (i, cardView) in cardViews.enumerated(){
                cardView.layer.removeAllAnimations()
                cardView.removeSafelyFromSuperview()
                self.addSubview(cardView)
                cardView.bothSidesView.flip(0, isFront: true)
                let point = points[i]
                let move = CABasicAnimation.move(0.4, to: point)
                if i == cardViews.count - 1{
                    self.animComp.add(move, completion: {
                        //アニメーションが終わったら、攻撃力ラベルを更新する
                        self.asyncBlock.next()
                    })
                }
                
                cardView.layer.add(move, forKey: "putDown")
            }
        }
    }
    
    func removeAll(_ cards: [Card]) {
        if cards.isEmpty{ return }
        asyncBlock.add{
            [weak self] in
            guard let `self` = self else {
                return
            }
            
            let cardViews = (cards as! [CardBattle]).map{ self.cardView($0) }
            //カードをアニメーションさせ、親Viewから除去する
            for cardView in cardViews{
                let move = CABasicAnimation.moveX(0.8, by: 50)
                self.animComp.add(move, completion: {
                    self.spotCollectionView.deleteAllData()
                    cardView.removeFromSuperview()
                    cardView.layer.removeAllAnimations()
                    
                    if cardView == cardViews.last!{
                        self.asyncBlock.next()
                    }
                })
                cardView.layer.add(move, forKey: "passing")
            }
        }
    }
    
//    func changeCardStrength(_ cardStrength: CardStrength) {
//
//    }
//
//    func changeSpotStatus(_ status: SpotStatus) {
//
//    }
    
    func cardView(_ card: CardBattle)-> CardView{
        let cardViews = ownerCardViews + enemyCardViews
        return cardViews.filter({ $0.card == card }).first!
    }
    
    func cardViewsInEnemyHand()-> [CardView]{
        return enemyCardViews.filter{
            $0.card != nil && self.battleMaster.battleField.enemy.hand.contains($0.card!)
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animComp.animationDidStop(anim, finished: flag)
    }
    
    @IBAction func touchUpSpot(_ sender: UIButton) {
        let spotCollectionView = SpotCollectionView(frame: bounds)
    }
}
