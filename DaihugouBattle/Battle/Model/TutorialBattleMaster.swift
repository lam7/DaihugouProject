//
//  TutorialBattleMaster.swift
//  DaihugouBattle
//
//  Created by main on 2019/06/16.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation

class TutorialBattleModel{
    let ownerCards: [CardBattle] = [1,2,8,10].map{ CardBattle(card: CardList.get(id: $0)!) }
    let enemyCards: [CardBattle] = [1,2,3,10].map{ CardBattle(card: CardList.get(id: $0)!) }
    
    func act0(_ battleMaster: TutorialBattleMaster){
        battleMaster.drawOwnerCards([ownerCards[0],ownerCards[1]])
        battleMaster.drawOwnerCards([enemyCards[0],enemyCards[1]])
        battleMaster.delegate?.startOwnerTurn()
        battleMaster.drawOwnerCards([ownerCards[2]])
    }
    
    let tutorialMessage1 = "大富豪プロジェクトの世界へようこそ！！\nこの世界では、カードを召喚し相手にダメージを与えてバトルをするよ。\nまずは、アリスを召喚してみよう！"
    func act1(_ battleMaster: TutorialBattleMaster){
        battleMaster.ownerPutDown([ownerCards[0]]){_ in}
    }
    
    let tutorialMessage2 = "よし、上手くカードを召喚できたみたいだね！\n次は、相手のターンだ"
    func act2(_ battleMaster: TutorialBattleMaster){
        battleMaster.delegate?.endOwnerTurn()
        battleMaster.delegate?.startEnemyTurn()
        battleMaster.drawEnemyCards([enemyCards[2]])
        battleMaster.enemyPutDown([ownerCards[1]]){_ in}
        battleMaster.delegate?.endEnemyTurn()
        battleMaster.delegate?.startEnemyTurn()
        battleMaster.drawOwnerCards([ownerCards[3]])
    }
    
    let tutorialMessage3 = "相手がインデックス～の～を召喚したみたいだね。\nインデックスとは、カードの左上に書かれた数字のことだよ。\nインデックスの役割はトランプの数字と一緒で、場に出されたインデックスより強いものしかカードを召喚できないんだ。\nインデックスの強さは革命時と非革命時の2つに分けられるよ。革命時では、数字が大きいほどインデックスが強いよ。逆に、非革命時では、数字が小さいほどインデックスが強いよ。\nさぁ、今度はコッチがカードを召喚する場合だよ。～を召喚してみよう。"
    func act3(_ battleMaster: TutorialBattleMaster){
        battleMaster.ownerPutDown([ownerCards[3]]){_ in}
        battleMaster.delegate?.endOwnerTurn()
        battleMaster.delegate?.startEnemyTurn()
        battleMaster.drawEnemyCards([enemyCards[3]])
    }
    let tutorialMessage4 = "相手がパスを選択したみたいだね。パスを選択すると攻撃にうつるよ。攻撃力は自分が召喚したカードの攻撃力の合計値×攻撃力レートで決まるよ。\nさぁ、攻撃にうつるよ。"
    func act4(_ battleMaster: TutorialBattleMaster){
        battleMaster.enemyPass(){_ in}
    }
    let tutorialMessage5 = "相手の体力が0になったね。君の勝利だ!"
    let tutorialMessage6 = "ヒント1\nカードの出し方は3つのグループに分かれます。\n1つめはさっき召喚したみたいなシングル。\nカード1枚出しのことを言うよ。\n2つめはグループ。\n同じインデックスのカードを複数枚だしすることを言うよ。\n3つめはステア。\nインデックスを階段状に3枚以上出すことを言うんだ。例えば、3,4,5や5,6,7,8などだね。\nグループやステアで4枚以上召喚すると、パスするまでの間1度だけ革命が発生するよ。\n革命が発生したら、インデックスの強さが入れ替わるよ。"
    let tutorialMessage7 = "ヒント2\nカードには、スキルが存在するものもあります。スキルは、貴方にとって戦況が有利となるよう様々な効果を恵んでくれます。スキルには発動条件があります。ここでは、一部紹介したいと思います。\nファンファーレ カード召喚時に発動\nラストワード どちらかのプレイヤーがパスを選び攻撃が終わった後に発動"
    let tutorialMessage8 = "ヒント3\nこの世界には色々な種類のカードが存在します。攻撃的なカードや守備的なカードなどを混じり合わせ貴方だけのデッキを作成しよう。\nここまで、チュートリアルを読んでくれてありがとう！"
    
    
}

class TutorialBattleMaster: BattleMaster{
    var delegate: BattleFieldDelegate?
    private(set) var battleField: BattleField!
    private let atkRatePerCard: Float = DefineServer.shared.floatValue("battleStandartAtkRate")
    private var ownerOriginalAtk: Int{ return battleField.spot.ownerCards.reduce(0, { $0 + $1.atk })}
    private var ownerAtkRate: Float{ return battleField.owner.atkRate }
    private var ownerAtk: Int{ return battleField.owner.atk }
    private var enemyOriginalAtk: Int{ return battleField.spot.enemyCards.reduce(0, { $0 + $1.atk })}
    private var enemyAtkRate: Float{ return battleField.enemy.atkRate }
    private var enemyAtk: Int{ return battleField.enemy.atk }
    
    init(){
        let owner = Owner(name: "チュートリアル", id: "0", maxHP: 10000)
        let enemy = Enemy(name: "敵", id: "1", maxHP: 2000)
        
        battleField = BattleField(owner: owner, enemy: enemy)
        owner.calcAtk = self.calcAtk
        enemy.calcAtk = self.calcAtk
    }
    
    private func calcAtk(_ originalAtk: Int, atkRate: Float)-> Int{
        return Int(originalAtk * atkRate)
    }
    
    func gameStart(_ completion: @escaping (Error?) -> ()){
        completion(nil)
    }
    
    func drawOwnerCards(_ cards: [Card]){
        battleField.owner.drawCards(cards)
    }
    
    func drawEnemyCards(_ cards: [Card]){
        battleField.owner.drawCards(cards)
    }
    
    private func putDown(_ cards: [Card], player: Player){
        player.putDown(cards)
        battleField.table.changeSpotStatus(by: cards)
        
        let atkRate = atkRatePerCard * cards.count
        player.changeAtkRate(inc: atkRate)
        if player.id == battleField.owner.id{
            print("ownerCards")
            player.changeOrignalAtk(to: ownerOriginalAtk)
        }else{
            print("enemyCards")
            player.changeOrignalAtk(to: enemyOriginalAtk)
        }
        
        player.activateSkill(cards, activateType: .fanfare)
        
        if cards.count >= 4{
            let current = battleField.table.currentCardStrength
            let next: CardStrength = current == .normal ? .revolution : .normal
            battleField.table.changeCurrentCardStrength(next)
        }
    }
    
    func ownerPutDown(_ cards: [Card], completion: @escaping (Error?) -> ()) {
        putDown(cards, player: battleField.owner)
        completion(nil)
    }
    
    func enemyPutDown(_ cards: [Card], completion: @escaping (Error?) -> ()) {
        putDown(cards, player: battleField.enemy)
        completion(nil)
    }
    
    func ownerPass(_ completion: @escaping (Error?) -> ()) {
        attack(false)
        battleField.table.changeSpotStatus(by: [])
        completion(nil)
    }
    
    func enemyPass(_ completion: @escaping (Error?) -> ()) {
        attack(true)
        battleField.table.changeSpotStatus(by: [])
        completion(nil)
    }
    
    private func attack(_ isFirstOwner: Bool){
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
        
        //テーブルにあるカードを流す
        battleField.spot.removeAll()
    }
}
