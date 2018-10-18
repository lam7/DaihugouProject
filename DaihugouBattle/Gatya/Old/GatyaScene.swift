//
//  GatyaScene.swift
//  Daihugou
//
//  Created by Main on 2017/06/16.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class GatyaScene: SKScene{
    ///後ろ向きのカードを載せるレイヤー
    private var backLayer: SKNode!
    ///前向きのカードを載せるレイヤー
    private var frontLayer: SKNode!
    ///背景
    private var background: SKSpriteNode?

    ///後ろ向きのカードノードの配列
    private var cardBack: [SKSpriteNode]!
    ///前向きのカードの配列
    private var cardFront: [CardSprite]!
    ///現在が演出のどのステップか表す
    private var currentPerform: Perform = Perform.Start
    ///演出中かどうか表す
    private var isPerform = false
    ///裏から表に向けた際、対応する要素をtrueにする
    ///全てtrueになったら次のステップへ移行
    private var isFlip: [Bool] = []

    ///後ろ向きのカードノードのオリジナル
    private var cardBackOriginal: SKSpriteNode!
    ///演出のためのパーティクルのオリジナル
    private let particleOriginal = SKEmitterNode(fileNamed: "GatyaParticle.sks")!
    ///カードを表に向けた際発生する音声のためのプレイヤー
    private var audioPlayer: AVAudioPlayer!

    ///ガチャの演出が一通り終わった時ボタンの表示を委譲
    var buttonDelegate: (() -> ())?

    /// キャラクタ詳細画面の遷移を委譲
    var characterDelegate: ((_ card: Card) -> ())?

    ///ガチャの演出のスッテプを表す
    private enum Perform{
        ///始まり
        case Start
        ///カードを並べる
        case LineUp
        ///カードをひっくり返す
        case CardTouch
        ///カードの一覧を表示し終わり演出の終了
        case Finish
    }
    override init(size: CGSize) {
        super.init(size: size)
        backLayer = SKNode()
        frontLayer = SKNode()
        self.addChild(backLayer)
        self.addChild(frontLayer)
        let height = size.height / 4
        let width = height * 3 / 4
        let cardSize = CGSize(width: width, height: height)

        let backTexture = SKTexture(image: DataRealm.get(imageNamed: "trumpBack.png")!)
        cardBackOriginal = SKSpriteNode(texture: backTexture)
        cardBackOriginal.size = cardSize
        cardBackOriginal.position = CGPoint(x: size.width / 2 - cardSize.width / 2, y: -(size.height / 2 - cardSize.height / 2))

        cardBack = []
        cardFront = []
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func touch(_ touches: Set<UITouch>){
        //演出中なら抜ける
        if isPerform{return}

        switch currentPerform {
        case .LineUp:
            //ステップをLineUpに移行してカードを並べる
            isPerform = true
            performLineUpCardInCircle(completion: {self.isPerform = false; self.currentPerform = .CardTouch})
        case .CardTouch:
            //座標を取得しそこにあるノードの裏カードをひっくり返す
            //裏カードは親ビューから取り除き表カードを表示する
            //カードのレアリティによる演出をする
            //全てのカードが表向きになったらカードの一覧を表示
            guard let position = touches.first?.location(in: self) else{
                return
            }
            guard let node = backLayer.nodes(at: position).first else{
                return
            }

            if isFlip[Int(node.name!)!]{
                return
            }

            let card = cardFront[Int(node.name!)!]
            self.cardBack[Int(node.name!)!].removeFromParent()
            card.sprite?.isHidden = false
            card.sprite?.position = self.cardBack[Int(node.name!)!].position
            let finish = {
                self.isFlip[Int(node.name!)!] = true
                var tmp = false
                for f in self.isFlip{
                    if !f{tmp = true}
                }

                if !tmp{
                    self.showAllCard(){
                        self.currentPerform = .Finish
                        self.buttonDelegate?()
                    }
                }
            }

            switch card.rarity {
            case .UR:
                performUR(card: card, completion: finish)
            case .SR:
                performSR(card: card, completion: finish)
            case .R:
                performRare(card: card, completion: finish)
            case .N:
                performNormal(card: card, completion: finish)
            }

        case .Finish:
            guard let position = touches.first?.location(in: self) else{
                return
            }
            guard let node = frontLayer.nodes(at: position).first else{
                return
            }
            let card = cardFront[Int(node.name!)!]
            characterDelegate?(card)
        default:
            break
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touch(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if currentPerform == .Finish{
            return
        }
        touch(touches)
    }

    ///背景画像をセット
    func set(background: UIImage){
        let texture = SKTexture(image: background)
        self.background = SKSpriteNode(texture: texture)
    }


    func touchOKButton(completion: @escaping () -> ()){
        for i in 0..<cardFront.count{
            let sprite = cardFront[i].sprite
            let action = SKAction.moveBy(x: size.width, y: 0, duration: 0.5)
            if i == cardFront.count - 1{
                sprite?.run(action, completion: {
                    sprite?.removeFromParent()
                    completion()
                })
            }else{
                sprite?.run(action, completion: {
                    sprite?.removeFromParent()
                })
            }

        }
    }

    ///  -TODO: エラーが起きたときの処理
    func set(card: [Card]){
        cardFront = []
        cardBack = []
        for c in card{
            let cardSprite = CardSprite(card: c)
            cardFront.append(cardSprite)
        }
        isFlip = [Bool](repeating: false, count: card.count)
        backLayer.removeAllChildren()
        frontLayer.removeAllChildren()
        createCardNode()
        performGatya()
    }

    /// -TODO: エラー処理
    private func createCardNode(){
        for i in 0..<cardFront.count{
            cardFront[i].sprite!.size = cardBackOriginal.size
            cardFront[i].sprite!.isHidden = true
            cardFront[i].sprite!.name = i.description
            cardBack.append(cardBackOriginal.copy() as! SKSpriteNode)
            cardBack[i].isHidden = true
            frontLayer.addChild(cardFront[i].sprite!)
            backLayer.addChild(cardBack[i])
        }
    }

    /// ガチャを引くボタンが押されて画面にユーザーが何らかの操作をするまでのガチャの演習
    ///
    /// - Parameter comletion: ガチャの演出が終わった後に呼ばれる
    private func performGatya(){
        for i in 0..<cardBack.count{
            cardBack[i].position = CGPoint(x: self.size.width / 2, y: (self.size.height / 2))
            cardBack[i].isHidden = false
        }
        currentPerform = .LineUp
    }


    /// ユーザーが何らかの操作をした後、ガチャからカードを円形状に並べる
    ///
    /// - Parameter completion: カードが並べ終わった後に呼ばれる
    private func performLineUpCardInCircle(completion: @escaping () -> ()){
        let waitDuration = 0.05
        let radius = self.size.height / 3
        let moveUpDuration = 0.4
        let rotateDuration = 1.5


        for i in 0..<cardBack.count{
            let card = cardBack[i]

            let waitAction = SKAction.wait(forDuration: waitDuration * (i+1).d)
            let moveUpAction = SKAction.move(by: CGVector.init(dx: 0, dy: radius), duration: moveUpDuration)
            let waitActionBeforeCircle = SKAction.wait(forDuration: moveUpDuration)
            let circlePosition = CGRect(x: radius, y: 0, width: -radius * 2, height: -radius * 2)
            let circle = UIBezierPath(roundedRect: circlePosition, cornerRadius: radius)
            let arc = UIBezierPath(arcCenter: CGPoint(x: 0, y: -radius), radius: radius, startAngle: (Double.pi / 2).cf, endAngle: (Double.pi / 2).cf + (Double.pi / 4 * i.d).cf, clockwise: true)
            let arcAction = SKAction.follow(arc.cgPath, duration: (rotateDuration / 8 * i.d))
            let moveCircleAction = SKAction.follow(circle.cgPath, duration: rotateDuration)
            let rotateZeroAction = SKAction.rotate(toAngle: 0, duration: 0.1)
            let rotateAction = SKAction.rotate(byAngle: (Double.pi / 2).cf, duration: 0.1)
            card.name = i.description
            card.run(waitAction){
                card.run(moveUpAction){
                    card.run(rotateAction){
                        card.run(waitActionBeforeCircle){
                            card.run(SKAction.group([moveCircleAction])){
                                card.run(arcAction){
                                    card.run(rotateZeroAction){
                                        self.cardFront[i].sprite!.position = self.cardBack[i].position
                                        if i == self.cardBack.count - 1{
                                            completion()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// ノーマルが出たときの演出
    ///
    /// - Parameters:
    ///   - card: カード
    ///   - completion: 演出の完了時に呼ばれる
    private func performNormal(card: CardSprite, completion: @escaping () -> ()){
//        audioPlayer.play()
        guard let sprite = card.sprite else{
            return
        }
        let particle = particleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        particle.particleColor = .white
        particle.particleColorBlendFactor = 1
        particle.particleColorSequence = nil
        particle.position = sprite.position
        self.addChild(particle)
        particle.run(SKAction.wait(forDuration: 0.8)){
            particle.removeFromParent()
            completion()
        }
    }


    /// レアが出たときの演出
    ///
    /// - Parameters:
    ///   - card: カード
    ///   - completion: 演出の完了時に呼ばれる
    private func performRare(card: CardSprite, completion: @escaping () -> ()){
//        audioPlayer.play()
        guard let sprite = card.sprite else{
            return
        }
        let particle = particleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        particle.particleColor = .brown
        particle.particleColorBlendFactor = 1
        particle.particleColorSequence = nil
        particle.position = sprite.position
        self.addChild(particle)
        particle.run(SKAction.wait(forDuration: 0.8)){
            particle.removeFromParent()
            completion()
        }
    }
    ///  スーパーレアが出たときの演出
    ///
    /// - Parameters:
    ///   - card: カード
    ///   - completion: 演出の完了時に呼ばれる
    private func performSR(card: CardSprite, completion: @escaping () -> ()){
//        audioPlayer.play()
        guard let sprite = card.sprite else{
            return
        }
        let particle = particleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        particle.particleColor = .lightGray
        particle.particleColorBlendFactor = 1
        particle.particleColorSequence = nil
        particle.position = sprite.position
        self.addChild(particle)
        particle.run(SKAction.wait(forDuration: 0.8)){
            particle.removeFromParent()
            completion()

        }
    }
    /// ウルトラレアが出たときの演出
    ///
    /// - Parameters:
    ///   - card: カード
    ///   - completion: 演出の完了時に呼ばれる
    private func performUR(card: CardSprite, completion: @escaping () -> ()){
//        audioPlayer.play()
        guard let sprite = card.sprite else{
            return
        }
        let particle = particleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        particle.particleColor = .yellow
        particle.particleColorBlendFactor = 1
        particle.particleColorSequence = nil
        particle.position = sprite.position
        self.addChild(particle)
        particle.run(SKAction.wait(forDuration: 0.8)){
            particle.removeFromParent()
            completion()
        }
    }

    /// 全てのカードを引き終わった後に全てのカードを
    ///　一覧に見せる
    /// - Parameter card: ガチャで得たカード
    private func showAllCard(completion: @escaping () -> ()){
        let width = cardBackOriginal.size.width
        let height = cardBackOriginal.size.height
        let count = cardFront.count
        let sx: CGFloat = 20
        let sy: CGFloat = 20
        let dx = ((self.size.width  - sx * 2 - width * ((count + 1) / 2))) / ((count + 1) / 2)
        let dy = (self.size.width - height * 2) / 2

        for i in 0..<count{
            let moveTo = CGPoint(x: sx + (dx + width) * i, y: sy + dy * i)
            let move = SKAction.move(to: moveTo, duration: 0.4)
            if i == cardFront.count - 1{
                cardFront[i].sprite?.run(move, completion: completion)
            }else{
                cardFront[i].sprite?.run(move)
            }
        }
    }

}


