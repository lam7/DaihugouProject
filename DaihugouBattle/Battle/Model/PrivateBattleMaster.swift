//
//  PrivateBattleMaster.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/10.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation


extension Errors{
    class Battle{
        static let isNotOwnerTurn = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "バトルエラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "あなたのターンではありません"])
        static let isNotEnemyTurn = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "バトルエラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "敵のターンではありません"])
        
        static let cannotPutDown = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "バトルエラー",
                                                                                        NSLocalizedFailureReasonErrorKey : "そのカードを出すことはできません"])
        
        static let notExistCardsInHand = NSError(domain: ErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : "バトルエラー",
                                                                                       NSLocalizedFailureReasonErrorKey : "手札に存在しないカードがあります"])
    }
}

protocol BattleFieldDelegate: class{
    func startOwnerTurn()
    func endOwnerTurn()
    func startEnemyTurn()
    func endEnemyTurn()
}

protocol BattleMaster{
    var delegate: BattleFieldDelegate?{ get set }
    var battleField: BattleField!{ get }
    func ownerPutDown(_ cards: [Card],  completion: @escaping (_ error: Error?) -> ())
    func ownerPass(_  completion: @escaping (_ error: Error?) -> ())
    func gameStart(_  completion: @escaping (_ error: Error?) -> ())
}

class LocalBattleMaster: BattleMaster{
    var delegate: BattleFieldDelegate?
    private(set) var battleField: BattleField!
    private var cpu: RandomCPU
    private var ownerDeck: DeckBattle
    private var enemyDeck: DeckBattle
    private(set) var isOwnerTurn: Bool
    private(set) var ownerElapsedTurn: Int
    private(set) var enemyElapsedTurn: Int
    private let atkRatePerCard: Float = DefineServer.shared.floatValue("battleStandartAtkRate")
    
    //最初にドローする枚数
    private let NumberOfInitialHands = DefineServer.shared.nsNumber("battleStandartInitialHands").intValue
    private let NumberOfRevolution = DefineServer.shared.nsNumber("battleStandartRevolution").intValue
    
    private var ownerOriginalAtk: Int{ return battleField.spot.ownerCards.reduce(0, { $0 + $1.atk })}
    private var ownerAtkRate: Float{ return battleField.owner.atkRate }
    private var ownerAtk: Int{
        var atk = ownerOriginalAtk
        atk = Int(atk * ownerAtkRate)
        return atk
    }
    private var enemyOriginalAtk: Int{ return battleField.spot.enemyCards.reduce(0, { $0 + $1.atk })}
    private var enemyAtkRate: Float{ return battleField.enemy.atkRate }
    private var enemyAtk: Int{
        var atk = enemyOriginalAtk
        atk = Int(atk * enemyAtkRate)
        return atk
    }
    
    init(ownerName: String, ownerId: PlayerIdType, ownerDeck: Deck, enemyName: String, enemyId: PlayerIdType, enemyDeck: Deck){
        let owner = Owner(name: ownerName, id: ownerId, maxHP: ownerDeck.cards.reduce(0, { $0 + $1.hp }))
        let enemy = Enemy(name: enemyName, id: enemyId, maxHP: enemyDeck.cards.reduce(0, { $0 + $1.hp }))
        battleField = BattleField(owner: owner, enemy: enemy)
        cpu = RandomCPU(player: enemy)
        self.ownerDeck = DeckBattle(deck: ownerDeck)
        self.enemyDeck = DeckBattle(deck: enemyDeck)
        ownerElapsedTurn = 0
        enemyElapsedTurn = 0
        isOwnerTurn = false

        owner.drawCards = self.drawOwnerCards
        enemy.drawCards = self.drawEnemyCards
    }
    
    func gameStart(_ completion: @escaping (Error?) -> ()){
        isOwnerTurn = Bool.random()
        ownerDeck.shuffle()
        enemyDeck.shuffle()
        drawOwnerCards(NumberOfInitialHands)
        drawEnemyCards(NumberOfInitialHands)
        
        if isOwnerTurn{
            ownerTurn()
        }else{
            enemyTurn()
        }
        completion(nil)
    }
    
    @discardableResult
    private func drawOwnerCards(_ amount: Int = 1)-> [Card]{
        let cards = ownerDeck.drawCards(amount)
        if !cards.filter({ $0 == nil }).isEmpty{
            battleField.owner.attacked(Int.max)
            return []
        }
        battleField.owner.drawCards(cards.compactMap{ $0 })
        return cards.compactMap({ $0 })
    }
    
    @discardableResult
    private func drawEnemyCards(_ amount: Int = 1)-> [Card]{
        let cards = enemyDeck.drawCards(amount)
        if !cards.filter({ $0 == nil }).isEmpty{
            battleField.enemy.attacked(Int.max)
            return []
        }
        battleField.enemy.drawCards(cards.compactMap{ $0 })
        return cards.compactMap({ $0 })
    }
    
    private func putDown(_ cards: [Card], player: Player) -> Error?{
        if cards.isEmpty{ return nil }
        
        var hand = player.hand
        //ハンドに全てのカードがあるかチェック
        guard cards.filter({ hand.contains($0) }).count == cards.count else{
            return Errors.Battle.notExistCardsInHand
        }
        
        for card in cards{
            let index = hand.firstIndex(of: card)!
            hand.remove(at: index)
        }
        
        player.putDown(cards)
        player.activateSkill(cards, activateType: .fanfare)
        battleField.table.changeSpotStatus(by: cards)
        
        let atkRate = atkRatePerCard * cards.count
        player.changeAtkRate(inc: atkRate)
        if player.id == battleField.owner.id{
            print("ownerCards")
            player.changeOrignalAtk(to: ownerOriginalAtk)
            player.changeAtk(to: ownerAtk)
        }else{
            print("enemyCards")
            player.changeOrignalAtk(to: enemyOriginalAtk)
            player.changeAtk(to: enemyAtk)
        }
        
        if cards.count >= NumberOfRevolution{
            let current = battleField.table.currentCardStrength
            let next: CardStrength = current == .normal ? .revolution : .normal
            battleField.table.changeCurrentCardStrength(next)
        }
        return nil
    }
    
    func ownerPutDown(_ cards: [Card], completion: @escaping (Error?) -> ()) {
        guard isOwnerTurn else{
            completion(Errors.Battle.isNotOwnerTurn)
            return
        }
        guard battleField.spot.canPutDown(cards) else{
            completion(Errors.Battle.cannotPutDown)
            return
        }
        
        if let error = putDown(cards, player: battleField.owner){
            completion(error)
            return
        }
        
        ownerTurnEnd()
        completion(nil)
    }
    
    func ownerPass(_ completion: @escaping (Error?) -> ()) {
        guard isOwnerTurn else{
            completion(Errors.Battle.isNotOwnerTurn)
            return
        }
        
        attack(false)
        battleField.table.changeSpotStatus(by: [])
        ownerTurnEnd()
        
        completion(nil)
    }
    
    private func ownerTurnEnd(){
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .ownerTurnEnd)
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .enemyTurnEnd)
    
        delegate?.endOwnerTurn()
        isOwnerTurn = !isOwnerTurn
        enemyTurn()
    }
    
    private func ownerTurn(){
        delegate?.startOwnerTurn()
        drawOwnerCards(1)
        
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .ownerTurnStart)
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .enemyTurnStart)
    }
    
    private func enemyTurn(){
        delegate?.startEnemyTurn()
        drawEnemyCards(1)
        
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnStart)
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnStart)

        let cards = cpu.act()
        
        if cards.isEmpty || putDown(cards, player: battleField.enemy) != nil{
            attack(true)
            battleField.table.changeSpotStatus(by: [])
        }
        
        enemyTurnEnd()
    }
    
    private func enemyTurnEnd(){
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnEnd)
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnEnd)
        
        delegate?.endEnemyTurn()
        isOwnerTurn = !isOwnerTurn
        ownerTurn()
    }
    
    func attack(_ isFirstOwner: Bool){
        let p1 = isFirstOwner ? battleField.owner : battleField.enemy
        let p2 = !isFirstOwner ? battleField.owner : battleField.enemy
        let p1Cards = isFirstOwner ? battleField.spot.ownerCards : battleField.spot.enemyCards
        let p2Cards = !isFirstOwner ? battleField.spot.ownerCards : battleField.spot.enemyCards
        
        p1.changeAtkRate(inc: 0.5)
        p1.activateSkill(p1Cards, activateType: .beforeAttack)
        let p1Atk = isFirstOwner ? ownerAtk : enemyAtk
        p1.attack(p1Atk)
        
        p2.activateSkill(p2Cards, activateType: .beforeAttack)
        let p2Atk = !isFirstOwner ? ownerAtk : enemyAtk
        p2.attack(p2Atk)
        
        p1.passingCametery(p1Cards)
        p1.activateSkill(p1Cards, activateType: .lastword)
        p2.passingCametery(p2Cards)
        p2.activateSkill(p2Cards, activateType: .lastword)
        
        p1.changeOrignalAtk(to: 0)
        p2.changeOrignalAtk(to: 0)
        p1.changeAtkRate(to: 1.0)
        p2.changeAtkRate(to: 1.0)
        p1.changeAtk(to: 0)
        p2.changeAtk(to: 0)
        
        //テーブルにあるカードを流す
        battleField.spot.removeAll()
    }
}
