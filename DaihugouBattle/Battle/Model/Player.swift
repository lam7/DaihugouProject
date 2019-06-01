//
//  Player.swift
//  Daihugou
//
//  Created by Main on 2017/05/17.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

typealias PlayerIdType = String

/// プレイヤーの行動をまとめたデリゲート
protocol PlayerDelegate: class {
    
    /// 攻撃時に呼ばれる
    ///
    /// - Parameters:
    ///   - amount: 攻撃量
    ///   - player: 攻撃するプレイヤー
    func attack(_ amount: Int, player: Player)
    
    /// 攻撃された時に呼ばれる
    ///
    /// - Parameters:
    ///   - amount: 攻撃量
    ///   - player: 攻撃されたプレイヤー
    func attacked(_ amount: Int, player: Player)
    
    ///回復時に呼ばれる
    ///
    /// - Parameters:
    ///   - amount: 回復量
    ///   - player: 回復したプレイヤー
    func heel(_ amount: Int, player: Player)
    
    /// カードをドローするときに呼ばれる
    ///
    /// - Parameters:
    ///   - normalCards: 通常にドローできたカード
    ///   - overCards: 所持可能枚数を超えたカード
    ///   - player: カードをドローしたプレイヤー
    func drawCards(_ normalCards: [Card], overCards: [Card], player: Player)
    
    /// デッキにカードがないときにドローしたときに呼ばれる
    ///
    /// - Parameters:
    ///   - emptyLv: からデッキから何枚ドローしようとしたか
    ///   - player: ドローしようとしたプレイヤー
//    func drawCards(_ emptyLv: Int, player: Player)
    
    /// ハンドから手札を捨てるときに呼ばれる
    ///
    /// - Parameters:
    ///   - cards: 捨てるカード
    ///   - player: カードを捨てたプレイヤー
    func removeHand(_ cards: [Card], player: Player)
    
    
    /// 攻撃力レートが増加したときに呼ばれる
    ///
    /// - Parameters:
    ///   - amount: 増加量
    ///   - player: レートが増加したプレイヤー
    func increaseAtkRate(_ amount: Float, player: Player)
    
    /// 攻撃力レートが減少したときに呼ばれる
    ///
    /// - Parameters:
    ///   - amount: 減少量
    ///   - player: レートが減少したプレイヤー
    func decreaseAtkRate(_ amount: Float, player: Player)
    
    func equalAtkRate(_ to: Float, player: Player)
    
    /// HPがゼロになるか、ある条件によりプレイヤーが死んだときに呼ばれる
    ///
    /// - Parameters:
    ///   - player: 死んだプレイヤー
    func death(_ player: Player)
    
    /// カードを出そうとしたときに呼ばれる
    ///　まだ、スポットにはカードが出されていない
    func willPutDown(_ cards: [Card], player: Player)
    
    func didPutDown(_ cards: [Card], player: Player)
    
    /// スキルが発動する直前に呼ばれる
    func activateSkill(_ card: Card, skill: Skill, player: Player)
    
    func changeAtk(_ to: Int, player: Player)
    
    func changeOrignalAtk(_ to: Int, player: Player)
}

class Player: NSCopying{
    /// プレイヤーId アカウント作成時に動的に作成されユニークな値
    fileprivate (set) var id: PlayerIdType
    ///手札
    fileprivate (set) var hand: [Card]{
        didSet{
            hand.sort(by: CardsSort.indexSort)
        }
    }
    ///墓地
    fileprivate (set) var cametery: [Card]
    
    ///攻撃値レート
    fileprivate (set) var atkRate: Float
    
    fileprivate (set) var originalAtk: Int
    
    var atk: Int{
        return calcAtk(originalAtk, atkRate)
    }
    
    var calcAtk: (_ originalAtk: Int, _ atkRate: Float)->(Int)
    
    ///プレイヤー名
    fileprivate (set) var name: String
    ///現在の体力
    fileprivate (set) var hp: Int
    
    fileprivate (set) var maxHP: Int
    //本来ならletだがその場合initでcalculateMaxHPをかます事ができなさそうなのでlazyとしている
    ///最大体力
//    public lazy var maxHP: Int = calculateMaxHP()
    
    public weak var battleField: BattleField!
    
    //　下位クラスで実装
    /// 敵
    public var enemy: Player!{
        return nil
    }
    ///テーブル
    public var table: Table!{
        return battleField.table
    }
    
    
    public var spot: Spot!{
        return battleField.spot
    }
    
    weak var delegate: PlayerDelegate?
    
    ///スキルのためのとりあえずの一時的なもの
    ///いずれクラス設計をより良くする必要がある
    var drawCards: ((_ amount: Int)-> ([Card]))?

    private init(player: Player){
        self.id = player.id
        self.hand = player.hand
        self.cametery = player.cametery
        self.name = player.name
        self.hp = player.hp
        self.maxHP = player.maxHP
        self.battleField = player.battleField
        self.originalAtk = player.originalAtk
        self.calcAtk = player.calcAtk
        self.atkRate = player.atkRate
    }
    
    init(name: String, id: PlayerIdType, maxHP: Int) {
        self.name = name
        self.id = id
        self.hand = []
        self.cametery = []
        self.hp = maxHP
        self.maxHP = maxHP
        self.originalAtk = 0
        self.atkRate = 1.0
        self.calcAtk = {
            ($0.f * $1).i
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Player(player: self)
    }

    /// ダメージを与える
    ///
    /// - Parameter amount: ダメージ量
    func attack(_ amount: Int) {
        delegate?.attack(amount, player: copy() as! Player)
        self.enemy?.attacked(amount)
    }
    
    /// プレイヤーにダメージを負わす
    ///
    /// - Parameter amount: ダメージ量
    func attacked(_ amount: Int){
        // 0未満にならないようなダメージ量を算出
        let dHp = hp - amount
        let damage = dHp <= 0 ? hp : amount
        self.hp -= damage
        delegate?.attacked(damage, player: copy() as! Player)
        
        if self.hp <= 0{
            delegate?.death(copy() as! Player)
        }
    }
    
    
    /// 体力を回復する
    ///
    /// - Parameter hp: 回復量
    func heel(_ amount: Int){
        //上限以下になる回復量を算出
        let dHp = hp + amount
        let heel = dHp >= maxHP ? maxHP - hp : amount
        self.hp += heel
    
        delegate?.heel(heel, player: copy() as! Player)
    }
    
    func drawCards(_ cards: [Card]){
        var normal: [Card] = []
        var over: [Card] = []
        for card in cards{
            if hand.count < table.maxHandCount {
                normal.append(card)
                hand.append(card)
            }else{
                over.append(card)
                cametery.append(card)
            }
        }
        
        let strength = table.currentCardStrength
        hand.sort(by: {
            strength.compare($1.index, $0.index)
        })
        
        delegate?.drawCards(normal, overCards: over, player: copy() as! Player)
    }
    
    /// スキルを発動させる
    ///
    /// - Parameters:
    ///   - cards: スキルが発動するかもしれないカード
    ///   - activateType: スキルを発動させるタイプ。cardsの内このタイプのカードがスキルを発動させる
    func activateSkill(_ cards: [Card], activateType: Skill.ActivateType){
        cards.forEach({ card in
            card.skills.forEach{
                if $0.activateType == activateType && $0.check(self){
                    delegate?.activateSkill(card, skill: $0, player: self)
                    $0.activate(self)
                }
            }
        })
    }
    
    /// 手札からカードを取り除く
    /// - Parameter cards: 取り除くカード
    fileprivate func deleteHand(_ cards: [Card]){
        for card in cards{
            if let index = hand.firstIndex(of: card){
                hand.remove(at: index)
            }else if let index = hand.firstIndex(of: cardNoData){
                hand.remove(at: index)
            }else{
                print("------------------------------------------------")
                print("Error Player-deleteHand")
                dump(cards)
                print("------------------------------------------------")
            }
        }
    }

    
    /// ハンドから指定のカードを墓地に流す
    ///
    /// ラストワードは発動しない
    /// - Parameter cards:
    func removeHand(_ cards: [Card]){
        deleteHand(cards)
        cametery += cards
        delegate?.removeHand(cards, player: copy() as! Player)
    }
    
    
    /// 全てのハンドを墓地に流す
    ///
    /// ラストワードは発動しない
    func removeAllHand(){
        let tmp = hand
        hand = []
        delegate?.removeHand(tmp, player: copy() as! Player)
    }
    
    /// テーブルにカードを出す
    func putDown(_ cards: [Card]){
        fatalError("Plase override this method.")
    }
    
    /// カードを墓地へ流す
    ///
    /// ラストワードが発動する
    /// - Parameter cards: 流すカードn
    func passingCametery(_ cards: [Card]){
        cametery += cards
    }
    
    func changeAtkRate(to amount: Float){
        atkRate = amount < 0 ? 0 : amount
        
        if atkRate < amount{
            atkRate = amount
            delegate?.increaseAtkRate(amount - atkRate, player: copy() as! Player)
        }else{
            let clip = amount < 0 ? 0 : amount
            atkRate = clip
            delegate?.decreaseAtkRate(atkRate - clip, player: copy() as! Player)
        }
        delegate?.changeAtk(atk, player: copy() as! Player)
    }
    
    func changeAtkRate(dec amount: Float){
        let d = atkRate - amount
        let clip = d < 0 ? atkRate : amount
        atkRate -= clip
        delegate?.decreaseAtkRate(clip, player: copy() as! Player)
        delegate?.changeAtk(atk, player: copy() as! Player)
    }
    
    func changeAtkRate(inc amount: Float){
        atkRate += amount
        delegate?.increaseAtkRate(amount, player: copy() as! Player)
        delegate?.changeAtk(atk, player: copy() as! Player)
    }
    
    func changeOrignalAtk(to amount: Int){
        self.originalAtk = amount
        delegate?.changeOrignalAtk(amount, player: copy() as! Player)
        delegate?.changeAtk(atk, player: copy() as! Player)
    }
}

class Owner: Player{
    public override var enemy: Player!{
        return battleField.enemy
    }
    /// テーブルにカードを出す
    ///
    /// ファンファーレが発動する
    /// - Parameter cards: 手札から出すカード
    override func putDown(_ cards: [Card]) {
        delegate?.willPutDown(cards, player: self)
        deleteHand(cards)
        spot.putDown(cards, isOwner: true)
        delegate?.didPutDown(cards, player: self)
    }
}

class Enemy:  Player{
    public override var enemy: Player!{
        return battleField.owner
    }
    
    /// テーブルにカードを出す
    ///
    /// ファンファーレが発動する
    /// - Parameter cards: 手札から出すカード
    override func putDown(_ cards: [Card]) {
        delegate?.willPutDown(cards, player: self)
        deleteHand(cards)
        spot.putDown(cards, isOwner: false)
        delegate?.didPutDown(cards, player: self)
    }
}
