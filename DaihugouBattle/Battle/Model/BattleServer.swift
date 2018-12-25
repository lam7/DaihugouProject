//
//  BattleServer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/05.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


protocol BattleServerDelegate: class{
    func gameStart()
    func enemyTurnStart()
    func enemyTurnEnd()
    func enemyDrawCards(_ cardCount: Int)
    func enemyPass()
    func enemyAttack(_ damage: Int)
    func enemyActivateSkill(_ card: Card)
    func enemyPutDowns(_ cards: [Card])
}

class BattleServerDecoder{
    private let rootRef = Database.database().reference()
    private let userRef  = Database.database().reference().child("users")
    private var roomId: String!
    private var newRoomId: String!
    private var targetId: String!
    private var chatStartFlg: Bool!
    private let userPath: String = UUID().uuidString
    weak var delegate: BattleServerDelegate?
    
    func setUp(){
        login({_ in
            self.getRoom()
        })
    }
    
    private func login(_ completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signInAnonymously{
            user, error in
            completion(error)
        }
    }
    
    private func getRoom(){
        let user: [String : String] = [
            "objectId" : UserLogin.objectIdUserInfo,
            "name" : UserInfo.shared.nameValue,
            "inRoom" : "0",
            "waitingFlg" : "0",
        ]

        userRef.child(userPath).setValue(user)
        
        //一回だけwaitingFlgが１のユーザを取得
        userRef.queryOrdered(byChild: "waitingFlg").queryEqual(toValue: "1").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary{
                if value.count >= 1{
                    //ルームを作る側の処理
                    print(value.count);
                    print("value \(value)")
                    print("↑初回ボタン押下時に、waitingFlgが１のユーザ")
                    self.createRoom(value: value as! Dictionary<AnyHashable, Any>)
                }
            } else {
                //ルームを作られるのを待つ側の処理
                self.userRef.child(self.userPath).updateChildValues(["waitingFlg":"1"])
                self.checkMyWaitingFlg()
            }
        })
    }
    
    private func checkMyWaitingFlg(){
        userRef.child(userPath).observe(DataEventType.childChanged, with: { (snapshot) in
            print(snapshot)
            let snapshotVal = snapshot.value as! String
            let snapshotKey = snapshot.key
            
            if (snapshotVal == "0" && snapshotKey == "waitingFlg"){
                self.getJoinRoom()
            }
        })
    }
    
    private func getJoinRoom(){
        userRef.child(userPath).child("inRoom").observeSingleEvent(of: .value, with: { (snapshot) in
            //返ってくる値が１つしか無いからstr型になる
            let snapshotValue = snapshot.value as! String
            self.roomId = snapshotValue
            if(self.roomId != "0"){
                print("roomId→ \(self.roomId!)")
                print("チャットを開始します")
                self.getMessages()
            }
        })
        
    }
    
    private func createRoom(value:Dictionary<AnyHashable, Any>){
        //chatを始めるユーザを取得。
        
        for (key,val) in value {
            
            if (key as! String != userPath){
                //待機中のユーザがいた場合(必ずこの処理で居るが)の処理
                print("待機中のユーザId\(key)")
                targetId = key as? String
            }
        }
        print("チャット開始するユーザId\(targetId!)")
        //新規のRoomを作るための数値を取得
        getNewRoomId()
    }
    
    private func getNewRoomId(){
        
        Database.database().reference().child("roomKeyNum").observeSingleEvent(of: .value, with: { (snapshot) in
            var count: Int = -1
            if !(snapshot.value is NSNull){
                count = (snapshot.value as! Int) + 1
            }else{
                print("getNewRoomId error")
                return
            }
            Database.database().reference()
                .child("roomKeyNum")
                .setValue(count)
            
            self.newRoomId = String(count)
            self.updateEachUserInfo()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    private func updateEachUserInfo(){
        
        roomId = newRoomId
        
        //ユーザ情報を書き換えていく。
        userRef.child(userPath).updateChildValues(["inRoom" : roomId!])
        userRef.child(userPath).updateChildValues(["waitingFlg" : "0"])
        
        //新しく作ったルームのidの情報を取ってくる処理【非同期】
        getMessages()
    }
    
    private func getMessages(){
        chatStartFlg = true
        
        //【非同期】子要素が増えるたびにmessageに値を追加する。
        rootRef.child("rooms").child(roomId!).queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            let text          = snapshotValue["activate"] as! String
            let name          = snapshotValue["id"] as! String
            print("display名前→\(name)")
        })
    }
    
    private func decode(_ activate: String){
        let activates = activate.components(separatedBy: ",")
        let activateType = activates[0]
        
        switch activateType {
        case "turnStart":
            delegate?.enemyTurnStart()
        case "turnEnd":
            delegate?.enemyTurnEnd()
        case "pass":
            delegate?.enemyPass()
        case "attack":
            delegate?.enemyTurnStart()
        case "draw":
            let amount = activates[1].i!
            delegate?.enemyDrawCards(amount)
        case "activateSkill":
            delegate?.enemyActivateSkill(CardList.get(id: 1)!)
        default:
            print("Irregal ActivateType: \(activateType)")
        }
    }
    
    func encodeOwnerTurnStart(_ id: String){
        encodeOwner(id, activate: "turnStart")
    }
    
    func encodeOwnerTurnEnd(_ id: String){
        encodeOwner(id, activate: "turnEnd")
    }
    
    func encodeOwnerPass(_ id: String){
        encodeOwner(id, activate: "pass")
    }
    
    func encodeOwnerAttack(_ id: String, damage: Int){
        encodeOwner(id, activate: "attack,\(damage)")
    }
    
    private func encodeOwner(_ id: String, activate: String){
        let activate: [String : String] = [
            "id" : id,
            "activate" : activate
        ]
        rootRef.child("rooms").child(roomId!).setValue(activate)
    }
}

//
//class FirebaseBattleMaster: BattleMaster{
//    var delegate: BattleFieldDelegate?
//    private(set) var battleField: BattleField!
//    private var cpu: RandomCPU
//    private var ownerDeck: DeckBattle
//    private var enemyDeck: DeckBattle
//    private var atkRate: BattleStandartAtkRate = BattleStandartAtkRate()
//    private(set) var isOwnerTurn: Bool
//    private(set) var ownerElapsedTurn: Int
//    private(set) var enemyElapsedTurn: Int
//    
//    //最初にドローする枚数
//    private let NumberOfInitialHands = 5
//    private let NumberOfRevolution = 4
//    
//    var spotAtkRate: Float!{ return atkRate.spotAtkRate(battleField.table.spotStatus) }
//    private var ownerOriginalAtk: Int{ return battleField.spot.ownerCards.reduce(0, { $0 + $1.atk })}
//    private var ownerAtkRate: Float{ return battleField.owner.atkRate }
//    private var ownerAtk: Int{
//        var atk = ownerOriginalAtk
//        atk = Int(atk * spotAtkRate)
//        atk = Int(atk * ownerAtkRate)
//        return atk
//    }
//    private var enemyOriginalAtk: Int{ return battleField.spot.enemyCards.reduce(0, { $0 + $1.atk })}
//    private var enemyAtkRate: Float{ return battleField.enemy.atkRate }
//    private var enemyAtk: Int{
//        var atk = enemyOriginalAtk
//        atk = Int(atk * spotAtkRate)
//        atk = Int(atk * enemyAtkRate)
//        return atk
//    }
//    
//    init(ownerName: String, ownerId: PlayerIdType, ownerDeck: Deck){
//        let enemyDeck = Deck.noDataDeck(ownerDeck.cards.count, type: CardBattle.self)
//        let owner = Owner(name: ownerName, id: ownerId, maxHP: ownerDeck.cards.reduce(0, { $0 + $1.hp }))
////        let enemy = Enemy(name: enemyName, id: enemyId, maxHP: enemyDeck.cards.reduce(0, { $0 + $1.hp }))
////        battleField = BattleField(owner: owner, enemy: enemy)
////        cpu = RandomCPU(player: enemy)
//        self.ownerDeck = DeckBattle(deck: ownerDeck)
//        self.enemyDeck = DeckBattle(deck: enemyDeck)
//        ownerElapsedTurn = 0
//        enemyElapsedTurn = 0
//        isOwnerTurn = false
//        
////        owner.drawCards = self.drawOwnerCards
////        enemy.drawCards = self.drawEnemyCards
//    }
//    
//    func calcPlayerAtk(_ cards: [Card], player: Player, completion: @escaping (Error?) -> ()) {
//        
//    }
//    
//    func gameStart(_ completion: @escaping (Error?) -> ()){
//        isOwnerTurn = Bool.random()
//        ownerDeck.shuffle()
//        enemyDeck.shuffle()
//        drawOwnerCards(NumberOfInitialHands)
//        drawEnemyCards(NumberOfInitialHands)
//        
//        if isOwnerTurn{
//            ownerTurn()
//        }else{
//            enemyTurn()
//        }
//        completion(nil)
//    }
//    
//    private func drawOwnerCards(_ amount: Int = 1){
//        let cards = ownerDeck.drawCards(amount)
//        if !cards.filter({ $0 == nil }).isEmpty{
//            battleField.owner.attacked(9999)
//        }else{
//            battleField.owner.drawCards(cards.compactMap{ $0 })
//        }
//    }
//    
//    private func drawEnemyCards(_ amount: Int = 1){
//        let cards = enemyDeck.drawCards(amount)
//        
//        battleField.enemy.drawCards(cards.compactMap{ $0 })
//        if !cards.filter({ $0 == nil }).isEmpty{
//            battleField.enemy.attacked(9999)
//        }
//    }
//    
//    private func putDown(_ cards: [Card], player: Player) -> Error?{
//        if cards.isEmpty{ return nil }
//        
//        var hand = player.hand
//        //ハンドに全てのカードがあるかチェック
//        guard cards.filter({ hand.contains($0) }).count == cards.count else{
//            return Errors.Battle.notExistCardsInHand
//        }
//        
//        for card in cards{
//            let index = hand.index(of: card)!
//            hand.remove(at: index)
//        }
//        
//        player.putDown(cards)
//        player.activateSkill(cards, activateType: .fanfare)
//        battleField.table.changeSpotStatus(by: cards)
//        
//        player.changeAtkRate(inc: 0.1)
//        if player.id == battleField.owner.id{
//            print("ownerCards")
//            player.changeOrignalAtk(to: ownerOriginalAtk)
//            player.changeAtk(to: ownerAtk)
//        }else{
//            print("enemyCards")
//            player.changeOrignalAtk(to: enemyOriginalAtk)
//            player.changeAtk(to: enemyAtk)
//        }
//        
//        if cards.count >= NumberOfRevolution{
//            let current = battleField.table.currentCardStrength
//            let next: CardStrength = current == .normal ? .revolution : .normal
//            battleField.table.changeCurrentCardStrength(next)
//        }
//        return nil
//    }
//    
//    func ownerPutDown(_ cards: [Card], completion: @escaping (Error?) -> ()) {
//        guard isOwnerTurn else{
//            completion(Errors.Battle.isNotOwnerTurn)
//            return
//        }
//        guard battleField.spot.canPutDown(cards) else{
//            completion(Errors.Battle.cannotPutDown)
//            return
//        }
//        
//        if let error = putDown(cards, player: battleField.owner){
//            completion(error)
//            return
//        }
//        
//        ownerTurnEnd()
//        completion(nil)
//    }
//    
//    func ownerPass(_ completion: @escaping (Error?) -> ()) {
//        guard isOwnerTurn else{
//            completion(Errors.Battle.isNotOwnerTurn)
//            return
//        }
//        
//        attack(false)
//        battleField.table.changeSpotStatus(by: [])
//        ownerTurnEnd()
//        
//        completion(nil)
//    }
//    
//    private func ownerTurnEnd(){
//        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .ownerTurnEnd)
//        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .enemyTurnEnd)
//        
//        delegate?.endOwnerTurn()
//        isOwnerTurn = !isOwnerTurn
//        enemyTurn()
//    }
//    
//    private func ownerTurn(){
//        delegate?.startOwnerTurn()
//        drawOwnerCards(1)
//        
//        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .ownerTurnStart)
//        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .enemyTurnStart)
//    }
//    
//    private func enemyTurn(){
//        delegate?.startEnemyTurn()
//        drawEnemyCards(1)
//        
//        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnStart)
//        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnStart)
//        
//        let cards = cpu.act()
//        
//        if cards.isEmpty || putDown(cards, player: battleField.enemy) != nil{
//            attack(true)
//            battleField.table.changeSpotStatus(by: [])
//        }
//        
//        enemyTurnEnd()
//    }
//    
//    private func enemyTurnEnd(){
//        battleField.enemy.activateSkill(battleField.spot.enemyCards, activateType: .ownerTurnEnd)
//        battleField.owner.activateSkill(battleField.spot.ownerCards, activateType: .enemyTurnEnd)
//        
//        delegate?.endEnemyTurn()
//        isOwnerTurn = !isOwnerTurn
//        ownerTurn()
//    }
//    
//    func attack(_ isFirstOwner: Bool){
//        let p1 = isFirstOwner ? battleField.owner : battleField.enemy
//        let p2 = !isFirstOwner ? battleField.owner : battleField.enemy
//        let p1Cards = isFirstOwner ? battleField.spot.ownerCards : battleField.spot.enemyCards
//        let p2Cards = !isFirstOwner ? battleField.spot.ownerCards : battleField.spot.enemyCards
//        
//        
//        p1.activateSkill(p1Cards, activateType: .beforeAttack)
//        let p1Atk = isFirstOwner ? ownerAtk : enemyAtk
//        p1.attack(p1Atk)
//        
//        p2.activateSkill(p2Cards, activateType: .beforeAttack)
//        let p2Atk = !isFirstOwner ? ownerAtk : enemyAtk
//        p2.attack(p2Atk)
//        
//        p1.passingCametery(p1Cards)
//        p1.activateSkill(p1Cards, activateType: .lastword)
//        p2.passingCametery(p2Cards)
//        p2.activateSkill(p2Cards, activateType: .lastword)
//        
//        p1.changeOrignalAtk(to: 0)
//        p2.changeOrignalAtk(to: 0)
//        p1.changeAtkRate(to: 1.0)
//        p2.changeAtkRate(to: 1.0)
//        p1.changeAtk(to: 0)
//        p2.changeAtk(to: 0)
//        
//        //テーブルにあるカードを流す
//        battleField.spot.removeAll()
//    }
//}
