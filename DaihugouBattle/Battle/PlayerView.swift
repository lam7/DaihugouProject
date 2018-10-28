//
//  PlayerView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/20.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

/*
 Tag
 1~45 それぞれの枚数時の手札位置
 100 DeckView
 101 HpGauseView
 102 IconImageView
 106 HandSupportView
 108 HandView
 */
class PlayerView: UIView, PlayerDelegate, CAAnimationDelegate{
    /// ハンドにあるカードの位置
    fileprivate lazy var handPoint: [[CGPoint]] = initHandPoint()
    
    var battleMaster: BattleMaster!
    
    /// プレイヤー
    /// 下位でオーバーライド
    var player: Player!{ return battleMaster.battleField.owner }
    var table: Table!{ return battleMaster.battleField.table }
    var spot: Spot!{ return battleMaster.battleField.spot }
    
    /// プレイヤー
    //    fileprivate var cards: [CardBattle]!
    
    /// アニメーション完了時処理
    fileprivate var animComp: CAAnimationCompletion<CAAnimationDelegate>!
    
    private(set) var cardViews: [CardView]!
    
    /// カードをドローするアニメーションにかかる時間
    var drawAnimationSp: TimeInterval = 0.6
    
    var death: (()->())?
    
    /// 子viewからそれぞれの位置を取り出して、そのViewを消す
    fileprivate func initHandPoint()-> [[CGPoint]]{
        var r: [[CGPoint]] = []
        for y in 1...9{
            //1 23 456 78910 1112131415
            var raw: [CGPoint] = []
            for x in 1...y{
                let view = self.viewWithTag(x + (y * (y - 1) / 2))!
                let center = view.superview!.convert(view.center, to: self)
                raw.append(center)
                view.removeFromSuperview()
                view.superview?.removeFromSuperview()
            }
            r.append(raw)
        }
        return r
    }
    
    
    /// デッキを表示するView
    lazy var deckView: UIView = self.viewWithTag(100)!
    
    /// HPゲージ
    lazy var hpGauseView: HpGaugeView = self.viewWithTag(101) as! HpGaugeView
    
    /// プレイヤーアイコンを表示するView
    lazy var iconImageView: UIImageView = self.viewWithTag(102) as! UIImageView
    
    /// プレイヤーのハンドを表示する範囲、大きさを決めるView
    lazy var handSupportView: UIView = self.viewWithTag(106)!
    
    /// ダメージを受けたりしたときに表示する数字ラベル
    lazy var damageLabel: UILabel = self.viewWithTag(107) as! UILabel
    
    /// ハンドを表示するView
    lazy var handView: UIView = self.viewWithTag(108)!
    
    /// 攻撃力を表示するView
    lazy var atkView: BattlePlayerAtkView = self.viewWithTag(109) as! BattlePlayerAtkView
    
    var chStatusView: CharacterStatusDetailView!
    var skillView: BattleSkillView!
    
    /// BattleField, Player, Spot 間で同期処理を非同期処理に変えるためのクラス
    var asyncBlock: ControllAsyncBlock{
        return BattleViewController.asyncBlock
    }
    
    
    /// このViewを初期化するときに絶対に呼ばれるべき処理
    ///
    /// パラメータをセットし、HPゲージ・デッキのカードViewを初期化する
    /// - Parameters:
    ///   - player: プレイヤー
    ///   - table: テーブル
    func set(battleMaster: BattleMaster)-> [CardView]{
//        guard let deck = player.deck.cards as? [CardBattle] else{
//            print("PlayerView - set(player:)")
//            print("Deck class is not [CardBattle]")
//            return
//        }
        self.battleMaster = battleMaster
        player.delegate = self
        hpGauseView.set(maxHp: player.maxHP)
        let count = StandartDeckCardsNum
        cardViews = []
        for _ in (0..<count).reversed(){
            let cardView = CardView(frame: deckView.frame)
            cardView.card = cardNoData
            cardView.bothSidesView.flip(0, isFront: false)
            cardViews.append(cardView)
        }
        cardViews.forEach{
            self.handView.addSubview($0)
        }
//        self.cardViews = []
//        deck.reversed().forEach({
//            let cardView = self.createCardView($0)
//            self.handView.addSubview(cardView.view)
//            self.cardViews.insert(cardView, at: 0)
//        })
        animComp = CAAnimationCompletion(parent: self)
        
        return cardViews
    }
    
//    func createCardView(_ card: CardBattle)-> CardView{
//        let cardView = CardView(frame: deckView.frame)
//        cardView.card = card
//        cardView.bothSidesView.flip(0, isFront: false)
//        return cardView
//    }
    
    /// -TODO: 複数枚出しでもステータスを表示できるように
    func willPutDown(_ cards: [Card], player: Player){
        print("willPutDown")
        asyncBlock.add {
            self.displayChStatus(cards.first)
            self.asyncBlock.next()
        }
        
    }
    
    func didPutDown(_ cards: [Card], player: Player) {
        
    }
    
    func attack(_ amount: Int, player: Player) {
        if amount == 0{
            
        }
        print(player.name + "の\(amount)の攻撃")
    }
    
    func attacked(_ amount: Int, player: Player) {
        if amount == 0{ return }
        asyncBlock.add{[weak self] in
            guard let `self` = self else{
                return
            }
            //1.2秒間でHpゲージを減少させ、ダメージ量を表示する
            self.hpGauseView.set(hp: player.hp, withDuration: 1.0, completion: nil)
            self.damageLabel.text = amount.description
            self.damageLabel.textColor = .red
            self.damageLabel.alpha = 1
            UIView.animate(withDuration: 1.2, animations: {
                self.damageLabel.alpha = 0
            }, completion: { _ in
                self.damageLabel.alpha = 0
                self.asyncBlock.next()
            })
            print(self.player.name + "に\(amount)のダメージ")
        }
    }
    
    func heel(_ amount: Int, player: Player) {
        asyncBlock.add{[weak self] in
            guard let `self` = self else{
                return
            }
            //1.2秒間でHpゲージを増加させ、回復量を表示する
            self.hpGauseView.set(hp: player.hp, withDuration: 1.2, completion: self.asyncBlock.next)
            self.damageLabel.text = amount.description
            self.damageLabel.alpha = 1
            self.damageLabel.textColor = .blue
            UIView.animate(withDuration: 1.2, animations: {[weak self] in
                guard let `self` = self else {
                    return
                }
                self.damageLabel.alpha = 0
                }, completion: {[weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    self.damageLabel.alpha = 0
            })
            print(self.player.name + "を\(amount)回復")
        }
    }
    
    func drawCards(_ normalCards: [Card], overCards: [Card], player: Player) {
        asyncBlock.add{[weak self] in
            guard let `self` = self else{
                return
            }
            let normalCards = normalCards as! [CardBattle]
            let overCards = overCards as! [CardBattle]
            
            let cardViews = self.cardViewNodata()
            let normalCardViews = cardViews[0..<normalCards.count].map{ $0 }
            let overCardViews  = cardViews[normalCards.count ..< (normalCards.count + overCards.count)].map{ $0 }
            for i in 0..<normalCards.count{ normalCardViews[i].card = normalCards[i] }
            for i in 0..<overCards.count{ overCardViews[i].card = overCards[i] }
            
            self.drawCardSupport(normalCardViews, overCards: overCardViews, player: player)
        }
    }
    
    func cardViewNodata()-> [CardView]{
        var c: [CardView] = []
        for i in 0..<cardViews.count{
            if cardViews[i].card == cardNoData{
                c.append(cardViews[i])
            }
        }
        return c
    }
    
    
    
    func cardView(_ card: CardBattle)-> CardView?{
        return cardViews.filter({ $0.card == card }).first
    }
    
    
    /// asyncBlock内で呼ばれる、ドローカードアニメーションy
    fileprivate func drawCardSupport(_ normalCards: [CardView], overCards: [CardView], player: Player){
        if !overCards.isEmpty{
            asyncBlock.next()
            return
        }
        let count: Int = player.hand.count
        let moveTo: [CGPoint] = handPoint[count - 1]
        let height: CGFloat = self.handSupportView.bounds.size.height * 0.8
        let width: CGFloat = height / 4 * 3
//        let dc = count - normalCards.count
//        let cx = handPoint[dc].reduce(0.0, { $0 + $1.x }) / dc
//        let fx = cx - (normalCards.count.cf / 2) * width

        for (i, card) in normalCards.enumerated(){
            let x = moveTo[count - normalCards.count + i].x
            let y = handSupportView.frame.minY
            let f = CGRect(x: x, y: y, width: width, height: height)
            UIView.animate(withDuration: drawAnimationSp, animations: {
                // それぞれのHandの位置へカードを移動させる
                card.frame = f
            }, completion: { _ in
                card.frame = f
                if i != normalCards.count - 1{ return }
                self.arrangeHandAnimation(player: player){[weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.asyncBlock.next()
                }
            })
        }
    }
    
    func drawCards(_ emptyLv: Int, player: Player) {
        
    }
    
    func removeHand(_ cards: [Card], player: Player) {
        let cards = cards as! [CardBattle]
        
        asyncBlock.add {[weak self] in
            guard let `self` = self else{
                return
            }
            //消すカードをフェードアウトさせる
            let cards = cards.map({self.cardView($0)}).compactMap({ $0 })
            for card in cards{
                UIView.animate(withDuration: 0.3, animations: {
                    card.alpha = 0
                }, completion:{ _ in
                    card.removeFromSuperview()
                    self.asyncBlock.next()
                })
            }
        }
    }
    
    func death(_ player: Player) {
        self.death?()
        print(player.name + "is Lose")
    }
    
    
    /// ハンドを整えるアニメーション
    ///
    /// - Parameters:
    ///   - duration: アニメーション時間
    ///   - player: プレイヤー
    ///   - completion: アニメーション完了時に呼ばれるブロック
    func arrangeHandAnimation(_ duration: TimeInterval = 0.25, player: Player, completion: @escaping () -> ()){
        if player.hand.isEmpty{
            completion()
            return
        }
        let count = player.hand.count
        let points = handPoint[count - 1]
        let cards = player.hand
        let hand = (cards as! [CardBattle]).map({ self.cardView($0) }).compactMap{ $0 }
        let y = self.handSupportView.frame.minY
        for (i, card) in hand.enumerated(){
            handView.bringSubviewToFront(card)
            UIView.animate(withDuration: duration, animations: {
                card.frame.origin.x = points[i].x
                card.frame.origin.y = y
            }, completion: { _ in
                card.frame.origin.x = points[i].x
                card.frame.origin.y = y
                if i == count - 1{
                    completion()
                }
            })
        }
    }
    
    func activateSkill(_ card: Card, activateType: Skill.ActivateType, player: Player) {
        let width: CGFloat = 120
        let height: CGFloat = width * 4 / 3
        let x = frame.midX - width / 2
        let y = frame.midY - height / 2
        asyncBlock.add {
            self.skillView.animation(card, completion: self.asyncBlock.next)
            let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            imageView.image = card.image
            self.addSubview(imageView)
            UIView.animate(withDuration: 1.6, animations: {
                imageView.alpha = 0
            }, completion: { _ in
                imageView.removeFromSuperview()
            })
            let animation = CABasicAnimation(keyPath: "position.y")
            animation.toValue = imageView.center.y + 20
            animation.duration = 0.4
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            imageView.layer.add(animation, forKey: "animation")
        }
    }
    
    func increaseAtkRate(_ amount: Float, player: Player) {
        asyncBlock.add {[weak self] in
            guard let `self` = self else {
                return
            }
            print("攻撃レート増加　\(amount) 現在値\(player.atkRate)")
            self.atkView.rateLabel.text = player.atkRate.description
//            self.atkView.atkLabel.text = self.battleMaster.ownerAtk.description.description
            self.asyncBlock.next()
        }
    }
    
    func decreaseAtkRate(_ amount: Float, player: Player) {
        asyncBlock.add {[weak self] in
            guard let `self` = self else {
                return
            }
            print("攻撃レート減少 \(amount) 現在地\(player.atkRate)")
            self.atkView.rateLabel.text = player.atkRate.description
//            self.atkView.atkLabel.text = self.battleMaster.ownerAtk.description.description
            self.asyncBlock.next()
        }
    }
    
    func equalAtkRate(_ to: Float, player: Player) {
        asyncBlock.add {[weak self] in
            guard let `self` = self else {
                return
            }
            print("攻撃レート\(to)に変更")
            self.atkView.rateLabel.text = player.atkRate.description
//            self.atkView.atkLabel.text = self.battleMaster.ownerAtk.description.description
            self.asyncBlock.next()
        }
    }
    
    func changeOrignalAtk(_ to: Int, player: Player) {
        asyncBlock.add {[weak self] in
            guard let `self` = self else {
                return
            }
            self.atkView.originalAtkLabel.text = to.description
            self.asyncBlock.next()
        }
    }
    
    func changeAtk(_ to: Int, player: Player) {
        asyncBlock.add {[weak self] in
            guard let `self` = self else {
                return
            }
            self.atkView.atkLabel.text = to.description
            self.asyncBlock.next()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animComp.animationDidStop(anim, finished: flag)
    }
    
    func displayChStatus(_ card: Card?){
        guard let card = card else{
            chStatusView.isHidden = true
            return
        }
        chStatusView.card = card
        chStatusView.isHidden = false
    }
    
}





class OwnerView: PlayerView{
    private var touchedCardView: CardView?
    override var player: Player!{
        return battleMaster.battleField.owner
    }
    
    override var atkView: BattlePlayerAtkView{
        didSet{
            atkView.titleLabel.text = "あなたの攻撃力"
        }
    }
    
    lazy var minHandSupportView: UIView = self.viewWithTag(200)  as! UIView
    
    fileprivate lazy var minHandFrame: [[CGRect]] = {
        var r: [[CGRect]] = []
        for y in 1...9{
            //1 23 456 78910 1112131415
            var raw: [CGRect] = []
            for x in 1...y{
                let view = minHandSupportView.viewWithTag(10000 + x + (y * (y - 1) / 2))!
                let frame = view.superview!.convert(view.frame, to: self)
                raw.append(frame)
                view.removeFromSuperview()
                view.superview?.removeFromSuperview()
            }
            r.append(raw)
        }
        return r
    }()
    
    var putDownCards: [CardBattle] = []
    
    /// カードを表に向けるアニメーションを追加
    override func drawCardSupport(_ normalCards: [CardView], overCards: [CardView], player: Player) {
        super.drawCardSupport(normalCards, overCards: overCards, player: player)
        normalCards.forEach{
            $0.bothSidesView.flip(drawAnimationSp, isFront: true)
        }
    }
    
    override func willPutDown(_ cards: [Card], player: Player) {
        super.willPutDown(cards, player: player)
        clearPutDownCards()
        removeFrame(cards as! [CardBattle])
    }
    
    /// タッチされたViewがハンドのカードならそのカードを返す
    /// - Parameter touch: タッチ
    /// - Returns: カード
    func getCardView(_ touch: UITouch)-> CardView?{
        guard let v = touch.view else{
            return nil
        }
        let hand = (player.hand as! [CardBattle]).map({self.cardView($0)}).compactMap({ $0 })
        return hand.filter({
            return $0 == v
            //            let c = $0.view.isBack ? $0.view.backView : $0.view.frontView
            //            return v == c
        }).first
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchedCardView = nil
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else{
            return
        }
        
        guard let cardView = getCardView(touch) else{
            displayChStatus(nil)
            let location = touch.location(in: self)
            print(location)
            if location.x >= bounds.width * 0.6 && location.y >= bounds.height * 0.6{
                switchToMinHandView()
            }
            return
        }
        displayChStatus(cardView.card)
        
        if !asyncBlock.isAsyncing{
            touchedCardView = cardView
        }
        //        if (putDownCards.contains(card) || card.view.frontView.layer.layer(with: "FrameLayer") != nil) && !asyncBlock.isAsyncing{
        //            touchedCard = card
        //        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = touchedCardView,
            let location = touches.first?.location(in: self) else{
                return
        }
        card.frame.origin = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let cardView = touchedCardView else{
            return
        }
        
        touchedCardView = nil
        var index = -1
        let hand = player.hand as! [CardBattle]
        for i in 0..<hand.count{
            if hand[i] == cardView.card{
                index = i
                break
            }
        }
        if index == -1{
            print("touchesEnded Index error")
            return
        }
        let pos = handPoint[player.hand.count - 1][index]
        if cardView.center.y <= bounds.height  * 2 / 3{
            cardView.frame.origin = CGPoint(x: pos.x, y: pos.y - cardView.frame.height)
            if !putDownCards.contains(cardView.card as! CardBattle){
                putDownCards.append(cardView.card as! CardBattle)
            }
            removeFrame()
            addFrame()
        }else{
            print("ClearPutDownCards")
            clearPutDownCards()
        }
    }
    
    
    func switchToMinHandView(){
        let hand = (player.hand as! [CardBattle]).map({self.cardView($0)}).compactMap({ $0 })
        UIView.animate(withDuration: 0.25, animations: {
            for (i, cardView) in hand.enumerated(){
                let f = self.minHandFrame[hand.count][i]
                cardView.frame = f
            }
        })
    }
    

    
    func clearPutDownCards(){
        putDownCards = []
        arrangeHandAnimation(0.25, player: player, completion: {[weak self] in
            guard let `self` = self else {
                return
            }
//            let hand = (self.player.hand as! [CardBattle]).map({self.cardView($0)}).compactMap({ $0 })
//            for c in hand{
//                c.layer.removeAnimation(forKey: "arrangeHand")
//                c.center = c.layer.presentation()!.position
//            }
        })
        removeFrame()
        addFrame()
    }
    
    func addFrame(){
//        let cards = possibleCards(player.hand, possible: putDownCards)
//        let hand = (self.player.hand as! [CardBattle]).map({self.cardView($0)})
//        hand.forEach({
//            if $0.layer.layer(with: "FrameLayer") == nil && cards.contains($0.card!){
//                let frameLayer = FrameLayer()
//                frameLayer.frame = $0.bounds
//                frameLayer.lineWidth = 5
//                frameLayer.color = UIColor.flatBlue().cgColor
//                frameLayer.name = "FrameLayer"
//                $0.layer.addSublayer(frameLayer)
//            }
//        })
    }
    
    func removeFrame(_ cards: [CardBattle]){
//        let cards = cards.map({self.cardView($0)})
//        cards.forEach({
//            if let layer = $0.layer.layer(with: "FrameLayer"){
//                layer.removeFromSuperlayer()
//            }
//        })
    }
    
    func removeFrame(){
//        let hand = (self.player.hand as! [CardBattle]).map({self.cardView($0)})
//        hand.forEach({
//            if let layer = $0.layer.layer(with: "FrameLayer"){
//                layer.removeFromSuperlayer()
//            }
//        })
    }
    
    func possibleCards(_ hand: [Card],  possible cards: [Card])-> [Card]{
        return hand
//        switch table.spotStatus {
//        case .empty:
//            if cards.isEmpty{
//                return hand
//            }
//            if table.checkIsSingle(cards){
//                let h = player.table.classify(player.hand)
//                let pair = h.pair
//                let stair = h.stair
//                var union = (pair + stair).flatMap({ $0 }).filter({ $0.contains(cards.first!) }).flatMap{ $0 }
//                union.removeDuplicates()
//                return union
//            }
//            if table.checkIsPair(cards){
//                var pair =  hand.filter{ $0.index == cards.first!.index }
//                pair.removeDuplicates()
//                return pair
//            }
//            if table.checkIsStairs(cards){
//                let h = player.table.classify(player.hand)
//                var stair = h.stair
//                stair = stair.filter({
//                    var flag = true
//                    $0.forEach({ c in
//                        hand.forEach({ h in
//                            if !c.contains(h){
//                                flag = false
//                                return
//                            }
//                        })
//                        if !flag{ return }
//                    })
//                    return flag
//                })
//                stair.removeDuplicates()
//                return stair
//            }
//        case .single:
//            if !cards.isEmpty{ return cards }
//
//            return hand.filter{ spot.canPutDown([$0]) }
//        case .pair(let count):
//            let h = player.table.classify(player.hand)
//            var pair = h.pair
//            pair = pair.filter{ spot.canPutDown($0) }
//            if !cards.isEmpty{
//                pair = pair.filter({ $0.first!.index == cards.first!.index })
//            }
//            var r = pair.flatMap({ $0 })
//            r.removeDuplicates()
//            return r
//        case .stairs(let count):
//            let hand = player.table.classify(player.hand)
//            var stair = hand.stair
//            stair = stair.filter({ s in
//                var flag = true
//                cards.forEach({
//                    c in
//                    if !s.contains(c){
//                        flag = false
//                        return
//                    }
//                })
//                return flag
//            })
//            var r = stair.flatMap({ $0 })
//            r.removeDuplicates()
//            return r
//        }
//        return []
    }
    
    override func arrangeHandAnimation(_ duration: TimeInterval, player: Player, completion: @escaping () -> ()) {
        super.arrangeHandAnimation(duration, player: player, completion: completion)
        removeFrame()
        addFrame()
    }
}



class EnemyView: PlayerView{
    override var player: Player!{
        return battleMaster.battleField.enemy
    }
    
    override var atkView: BattlePlayerAtkView{
        didSet{
            atkView.titleLabel.text = "敵の攻撃力"
        }
    }
    
    override func willPutDown(_ cards: [Card], player: Player) {
        asyncBlock.add {
            let cardViews = self.cardViewNodata()
            for i in 0..<cards.count{
                cardViews[i].card = cards[i]
            }
            self.asyncBlock.next()
        }
        
    }
    
    override func drawCardSupport(_ normalCards: [CardView], overCards: [CardView], player: Player){
        super.drawCardSupport(normalCards, overCards: overCards, player: player)
        normalCards.forEach{
            $0.bothSidesView.flip(drawAnimationSp, isFront: false)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self{
            return nil
        }
        return view
    }
}
