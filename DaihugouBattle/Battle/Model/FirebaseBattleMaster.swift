//
//  FirebaseBattleMaster.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/22.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation



class FirebaseBattleMaster: BattleMaster{
    var battleField: BattleField!
    var battleRoom: FirebaseBattleRoom
    var delegate: BattleFieldDelegate?
    
    var spotAtkRate: Float! = 1.0
    var isOwnerTurn: Bool = false
    private var ownerDeck: DeckBattle
    private let NumberOfInitialHands = 5
    private let NumberOfRevolution = 4
    
    
    init(){
        battleRoom = FirebaseBattleRoom()
    }
    
    func matching(_ completion: @escaping (_ error: Error?) -> ()){
        battleRoom.setUp(completion)
    }
    
    func gameStart(_ completion: @escaping (Error?) -> ()){
        ownerDeck.shuffle()
        drawOwnerCards(NumberOfInitialHands)
        drawEnemyCards(NumberOfInitialHands)
        
        if isOwnerTurn{
            ownerTurn()
        }else{
            enemyTurn()
        }
        completion(nil)
    }
    
    private func drawOwnerCards(_ amount: Int = 1){
        let cards = ownerDeck.drawCards(amount)
        if !cards.filter({ $0 == nil }).isEmpty{
            battleField.owner.attacked(9999)
        }else{
            battleField.owner.drawCards(cards.compactMap{ $0 })
        }
        
    }
    
    private func drawEnemyCards(_ amount: Int = 1){
        let cards = (0 ..< amount).map{ _ in CardBattle(card: cardNoData) }
        battleField.enemy.drawCards(cards.compactMap{ $0 })
    }
    
    private func putDown(_ cards: [Card], player: Player) -> Error?{
        if cards.isEmpty{ return nil }
        
        var hand = player.hand
        //ハンドに全てのカードがあるかチェック
        guard cards.filter({ hand.contains($0) }).count == cards.count else{
            return Errors.Battle.notExistCardsInHand
        }
        
        for card in cards{
            let index = hand.index(of: card)!
            hand.remove(at: index)
        }
        
        player.putDown(cards)
        player.activateSkill(cards, activateType: .fanfare)
        battleField.table.changeSpotStatus(by: cards)
        
        player.changeAtkRate(inc: 0.1)
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
    
    private func startEnemyTurn(){
        delegate?.startEnemyTurn()
        
        battleField.owner.drawCards([cardNoData])
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnStart)
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnStart)
    }
    
    private func enemyPutDown(_ cards: [Card]){
        delegate?.startEnemyTurn()
        
        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnStart)
        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnStart)
        
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
    
    private func enemyTurn(){
        
    }
}

