////
////  BattleScene.swift
////  DaihugouBattle
////
////  Created by Main on 2017/10/02.
////  Copyright © 2017年 Main. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//
//protocol BattleSceneDelegate{
//    func cardDescription(_ card: CardBattle?)
//    func updateSumAtk(_ owner: Int, enemy: Int)
//}
//class BattleScene: SKScene{
//    private var battleField: BattleField!
//
//    /// ボタンや画像などと重ならないy座標
//    ///
//    /// おそらくownerのimageViewの座標がこの座標となる
//    var ownerSafeYPosition: CGFloat!
//    /// ボタンや画像などと重ならないy座標
//    ///
//    /// おそらくenemyのimageView + imageView.heihtの座標がこの座標となる
//    var enemySafeYPosition: CGFloat!
//
//    /// カードサイズ
//    private var cardSpriteSize: CGSize!
//    /// オーナーのデッキ位置
//    private var ownerDeckPosition: CGPoint!
//    /// 敵のデッキ位置
//    private var enemyDeckPosition: CGPoint!
//    /// 手札のx座標
//    private var handXPosition: [[CGFloat]]{
//        let card = cardSpriteSize.width
//        let width = self.size.width
//        let center = self.frame.width / 2
//        let n = card / 2
//        let x: [[CGFloat]] = [
//            [],
//            [center],
//            [center - card, center + card],
//            [center - card, center, center + card],
//            [center - card * 1.5, center - card * 0.5, center + card * 0.5, center + card * 1.5],
//            [center - card * 1.5, center - card * 0.5, center, center + card * 0.5, center + card * 1.5],
//            [],
//            [],
//            [],
//            [width / 4, n, n * 2, n * 3, n * 4, n * 5, n * 6, n * 7, n * 8]
//            ]
//        return x
//    }
//
//    /// オーナーの手札のy位置
//    private var ownerHandYPosition: CGFloat!
//    /// 敵の手札のy位置
//    private var enemyHandYPosition: CGFloat!
//
//    private lazy var spotCenterPosition = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//    private lazy var spotPositionRange: CGFloat = 20
//
//    private let drawDuration: TimeInterval = 0.8
//
//    private var ownerLayer: SKNode!
//    private var enemyLayer: SKNode!
//    private var ownerHandLayer: SKNode!
//    private var enemyHandLayer: SKNode!
//    private var tableLayer: SKNode!
//
//    private var touchNode: SKNode?
//    private var putDownNodes: [SKNode]  = []
//    private var putDownCards: [CardBattle]{
//        var tmp: [CardBattle] = []
//        for node in putDownNodes{
//            tmp += battleField.owner.hand.filter({ $0.sprite == node })
//        }
//        return tmp
//    }
//
//    private let cardSpriteSizeRatio: CGFloat = 8
//
//    var displayDelegate: BattleSceneDelegate?
//
//    private var randomCPU: RandomCPU!
//
//
//    override init(size: CGSize) {
//        self.cardSpriteSize = CGSize(width: size.width / cardSpriteSizeRatio, height: size.width / cardSpriteSizeRatio * 4 / 3)
//        self.ownerDeckPosition = CGPoint(x: size.width, y: size.height / 2 - cardSpriteSize.height / 2)
//        self.enemyDeckPosition = CGPoint(x: size.width, y: size.height / 2 + cardSpriteSize.height / 2)
//        self.ownerHandYPosition = 0
//        self.enemyHandYPosition = 0
//        super.init(size: size)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//        ownerLayer = SKNode()
//        ownerHandLayer = SKNode()
//        enemyLayer = SKNode()
//        enemyHandLayer = SKNode()
//        tableLayer = SKNode()
//        self.addChild(tableLayer)
//        self.addChild(enemyLayer)
//        self.addChild(ownerLayer)
//        ownerLayer.addChild(ownerHandLayer)
//        enemyLayer.addChild(enemyHandLayer)
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else{
//            return
//        }
//        let nodes = ownerHandLayer.nodes(at: touch.location(in: ownerHandLayer))
//        touchNode = nodes.first
//        let card = battleField.owner.hand.filter({ $0.sprite == touchNode }).first
//        displayDelegate?.cardDescription(card)
//
//        return
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else{
//            return
//        }
//        guard let touchNode = touchNode else{
//            return
//        }
//        touchNode.position = touch.location(in: self)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let node = touchNode else{
//            return
//        }
//        if node.position.y >= self.frame.height / 4{
//            putDownNodes.append(node)
//            moveToWillPutDownPosition(putDownCards.last!, completion: {})
//        }else{
//            for (index, card) in putDownNodes.enumerated(){
//                if card == node{
//                    putDownNodes.remove(at: index)
//                    break
//                }
//            }
//            moveToRespectiveHandPosition(true, completion: {})
//        }
//        touchNode = nil
//    }
//
//    func touchUpPutDownButton()-> Bool{
//        if battleField.table.checkPutDown(putDownCards){
//            moveToSpotPosition(putDownNodes, completion: {
//                self.putDownNodes.forEach({ $0.removeFromParent(); self.tableLayer.addChild($0) })
//                self.battleField.owner.putDown(self.putDownCards)
//                let spot = self.battleField.table.spot
//                self.displayDelegate?.updateSumAtk(spot.sumOwnerAtk, enemy: spot.sumEnemyAtk)
//                self.putDownNodes = []
//                self.drawCard(isOwner: false, completion: {
//                    let act = self.randomCPU.act()
//                    print("act")
//                    print(act)
//                    self.enemyAct(act, completion: {
//                        self.drawCard(isOwner: true, completion: {})
//                    })
//                })
//
//            })
//
//            return true
//        }else{
//            print("出せません")
//            return false
//        }
//    }
//
//    func touchUpPassButton(){
//    }
//
//    func set(battleField: BattleField, ownerSafeYPosition: CGFloat, enemySafeYPosition: CGFloat){
//        self.battleField = battleField
//        self.randomCPU = RandomCPU(player: battleField.enemy, table: battleField.table)
//        self.ownerSafeYPosition = self.frame.height - ownerSafeYPosition
//        self.enemySafeYPosition = self.frame.height - enemySafeYPosition
//        self.ownerHandYPosition = self.ownerSafeYPosition + cardSpriteSize.height / 2
//        self.enemyHandYPosition = self.enemySafeYPosition
//        createDeck(true)
//        createDeck(false)
//        drawCard(9, isOwner: true, completion: {})
//        drawCard(9, isOwner: false, completion: {})
//
//    }
//
//    private func createDeck(_ isOwner: Bool){
//        let player = isOwner ? battleField.owner : battleField.enemy
//        let deckPosition = isOwner ? ownerDeckPosition : enemyDeckPosition
//        let layer = isOwner ? ownerLayer : enemyLayer
//
//        for (index, card) in player.deck.reversed().enumerated(){
//            card.sprite?.size = cardSpriteSize
//            card.sprite?.position = deckPosition!
//            card.sprite?.name = index.description
//            let rotate =  SKAction.rotate(toAngle: CGFloat.pi / 180 * (isOwner ? 80 : 100), duration: 0)
//            card.sprite?.run(rotate)
//            layer?.addChild(card.sprite!)
//        }
//    }
//
//    func drawCard(_ amount: Int = 1, isOwner: Bool, completion: @escaping () -> ()){
//        let player = isOwner ? battleField.owner : battleField.enemy
//        let layer = isOwner ? ownerHandLayer : enemyHandLayer
//        let cards = player.drawCard(amount)
//        for (index, card) in cards.enumerated(){
//            let x = self.handXPosition[player.hand.count][player.hand.count - cards.count + index]
//            let y = isOwner ? ownerHandYPosition : enemyHandYPosition
//            let moveTo = CGPoint(x: x, y: y!)
//            let rotateAction = SKAction.rotate(toAngle: 0, duration: self.drawDuration)
//            let moveAction = SKAction.move(to: moveTo, duration: self.drawDuration)
//            let groupAction = SKAction.group([rotateAction, moveAction])
//            card.sprite?.removeFromParent()
//            layer?.addChild(card.sprite!)
//            if cards.count - 1 == index{
//                card.sprite?.run(groupAction, completion: {
//                    self.moveToRespectiveHandPosition(isOwner, completion: completion)
//                })
//            }else{
//                card.sprite?.run(groupAction)
//            }
//        }
//    }
//
//    private func moveToRespectiveHandPosition(_ isOwner: Bool, completion: @escaping () -> ()){
//        let player = isOwner ? battleField.owner : battleField.enemy
//        for (index, card) in player.hand.enumerated(){
//            let x = self.handXPosition[player.hand.count][index]
//            let y = isOwner ? self.ownerHandYPosition! : self.enemyHandYPosition!
//            let moveTo = CGPoint(x: x, y: y)
//            let moveAction = SKAction.move(to: moveTo, duration: 0.2)
//            if player.hand.count - 1 == index{
//                card.sprite?.run(moveAction, completion: completion)
//            }else{
//                card.sprite?.run(moveAction)
//            }
//        }
//    }
//
//    private func moveToSpotPosition(_ cards: [SKNode], completion: @escaping () -> ()){
//        let xPositions = cards.map({ $0.position.x })
//        let center = xPositions.reduce(0, { $0 + $1 }) / xPositions.count
//        let moveToY = self.spotCenterPosition.y +- self.spotPositionRange
//        for (index, card) in cards.enumerated(){
//            let moveToX = self.spotCenterPosition.x + center - card.position.x
//            let moveTo = CGPoint(x: moveToX, y: moveToY)
//            let moveAction = SKAction.move(to: moveTo, duration: 0.3)
//
//            if index == cards.count - 1{
//                card.run(moveAction, completion: completion)
//            }else{
//                card.run(moveAction)
//            }
//        }
//    }
//
//    private func moveToWillPutDownPosition(_ card: CardBattle, completion: @escaping () -> ()){
//        for (index, owner) in battleField.owner.hand.enumerated(){
//            if owner.sprite == card.sprite{
//                let x = handXPosition[battleField.owner.hand.count][index]
//                let y = ownerHandYPosition + cardSpriteSize.height / 2
//                let moveTo = CGPoint(x: x, y: y)
//                let moveAction = SKAction.move(to: moveTo, duration: 0.1)
//                card.sprite?.run(moveAction)
//            }
//        }
//    }
//
//    func enemyAct(_ cards: [CardBattle], completion: @escaping () -> ()){
//        if cards.isEmpty{
//            completion()
//            return
//        }
//
//        moveToSpotPosition(cards.map({ $0.sprite! }), completion: {
//            cards.forEach({ $0.sprite?.removeFromParent(); self.tableLayer.addChild($0.sprite!)})
//            self.battleField.enemy.putDown(cards)
//            let spot = self.battleField.table.spot
//            self.displayDelegate?.updateSumAtk(spot.sumOwnerAtk, enemy: spot.sumEnemyAtk)
//            completion()
//        })
//    }
//
//}
//
//
