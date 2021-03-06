//
//  GatyaRollViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GatyaRollViewController: UIViewController{
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var characterDetailView: ClosableCharacterDetailView!
    @IBOutlet weak var cardsView: UIView!
    @IBOutlet weak var cardOriginalView: UIView!
    @IBOutlet weak var packImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var particleView: GatyaParticleView!
    @IBOutlet weak var packEffectImageView: UIImageView!
    @IBOutlet weak var sceneView: SceneView!
    
    var gatya: Gatya!
    private var getCards: [Card]!
    private var selectedCard: Card?
    private let RollCountOnceGatya = 8
    private var isPerform: Bool!
    private var currentStep: AnimationStep!
    /// アニメーションのスピード
    ///
    /// 値が大きいほど早くなる
    private var animationSpeedRate: TimeInterval = 1.0
    private var isFirstAnimation: Bool = true
    private lazy var listCardFrame: [CGRect] = {
        var frames: [CGRect] = []
        for i in 1...8{
            guard let view = self.view.viewWithTag(i + 100) else{
                continue
            }
            var bounds = view.bounds
            bounds = self.view.convert(bounds, from: view)
            frames.append(bounds)
            if i == 4 || i == 8{
                view.removeAllSubviews()
                view.removeFromSuperview()
            }
        }
        return frames
    }()
    
    private enum AnimationStep{
        ///始まり
        case start
        ///カードを並べる
        case lineUp
        ///カードをひっくり返す
        case cardTouch
        ///カードの一覧を表示し終わり演出の終了
        case finish
    }
    
    override func loadView() {
        super.loadView()
        createCardView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        OuterFrameClosableView.show(characterDetailView)
        backgroundImageView.image = DataRealm.get(imageNamed: "gatyaStandartBackground.png")
        ManageAudio.shared.addAudioFromRealm("se_gatya_iainuki.mp3", audioType: .se)
        ManageAudio.shared.addAudioFromRealm("se_card_flip.mp3", audioType: .se)
        ManageAudio.shared.addAudioFromRealm("shakin2.mp3", audioType: .se)
        particleView.scene.setUpNormalParticle()
        sceneView.presentScene(GifEffectScene.self)
        if let image = DataRealm.get(imageNamed: "gatya_kourin.png"){
            let images = image.divImage(2, yNum: 8)
            (sceneView.scene as! GifEffectScene).createNode(gif: images, position: packImageView.center, scale: 0.5)
        }
    }
    
    private func createCardView(){
        //-TODO: ガチャの種類によりカードの裏面や背景を変えたりする
        let b = cardOriginalView.bounds
        for _ in (0 ..< RollCountOnceGatya).reversed(){
            let cardView = CardView(frame: b)
            self.cardsView.addSubview(cardView)
        }
    }

    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        LoadingView.show()
        self.view.isUserInteractionEnabled = true
        isPerform = true
        
        packImageView.image = DataRealm.get(imageNamed: "gatyaStandart.png")
        gatya.roll(){
            [weak self] cards, error in
            guard let `self` = self else{
                return
            }
            if let error = error{
                self.present(error, completion: nil)
                return
            }
            print("gatyaEnd")

            self.getCards = cards
            self.takeOutCards()
            self.currentStep = .start
            self.isPerform = false
            LoadingView.hide()
        }
        okButton.isHidden = true
        backButton.isHidden = true
        skipButton.isHidden = false
    }
    
    override func didMove(toParent parent: UIViewController?) {
        getCards = []
        selectedCard = nil
        ManageAudio.shared.removeAudio("se_gatya_iainuki.mp3")
        ManageAudio.shared.removeAudio("se_card_flip.mp3")
    }
    
    private func present(_ error: Error, completion: (() -> ())!){
        let errorAlart = UIAlertController(title: "エラー", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "前の画面に戻る", style: .default, handler: {
            [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        })
        errorAlart.addAction(alertAction)
        errorAlart.message = error.localizedDescription
        self.present(errorAlart, animated: true, completion: completion)
    }
    
    private func takeOutCards(){
        for i in (0 ..< RollCountOnceGatya).reversed(){
            guard let card = getCards[safe: i] else{
                continue
            }
            let cardView = cardsView.subviews[i] as! CardView
            cardView.card = card
            cardView.layer.removeAllAnimations()
            cardView.center = cardOriginalView.center
            cardView.bothSidesView.flip(0, isFront: false)
            getCards.remove(at: i)
        }
    }
    
    private func packScaleAnimation(_ duration: TimeInterval)-> CAKeyframeAnimation{
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.keyTimes = [0, 0.5, 0.75, 0.9, 1]
        animation.values = [1, 0.7, 1.2, 0.9, 1.1]
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
        return animation
    }
    
    private func packAnimation(_ duration: TimeInterval, completion: @escaping () -> ()){
        CATransaction.begin()
        let ecAnimation = packScaleAnimation(duration)
        (self.sceneView.scene as! GifEffectScene).startGif()
        ManageAudio.shared.play("se_gatya_iainuki.mp3")
        CATransaction.setCompletionBlock{
            [weak self] in
            guard let `self` = self else{
                return
            }
            completion()
            CATransaction.begin()
            let moveAnimation = CABasicAnimation.move(0.8, by: CGPoint(x: 30, y: 8))
            let hiddenAnimation = CABasicAnimation.hidden(0.8, to: true)
            CATransaction.setCompletionBlock{
                [weak self] in
                guard let `self` = self else{
                    return
                }
                self.packImageView.layer.removeAllAnimations()
                self.packImageView.isHidden = true
            }
            self.packImageView.layer.add(moveAnimation, forKey: "moveAnimation")
            self.packImageView.layer.add(hiddenAnimation, forKey: "hiddenAnimation")
            CATransaction.commit()
        }
        packImageView.layer.add(ecAnimation, forKey: "ecAnimation")
        CATransaction.commit()
        
        packEffectImageView.animationDuration = duration * 0.6
    }
    
    
    private func circlePath(_ radius: CGFloat, arcCenter: CGPoint, to angle: CGFloat)-> UIBezierPath{
        return UIBezierPath(arcCenter: arcCenter, radius: radius,
                               startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 1.5 - angle, clockwise: false)
    }
    
    
    private func circleAnimation(_ duration: TimeInterval, radius: CGFloat, angle: CGFloat)-> CAAnimation{
        let path = circlePath(radius, arcCenter: view.center, to: angle)
        let move = CAKeyframeAnimation.move(duration, by: path)
        let rotate = CABasicAnimation.rotateZ(duration, by: -angle)
        rotate.isCumulative = true
        let group = CAAnimationGroup()
        group.animations = [move, rotate]
        group.setDurationToSameTimeSpawn()
        return group
    }
    
    private func animationAfterSecond(_ completion: @escaping() -> ()){
        let count = RollCountOnceGatya
        let radius = self.view.frame.size.height / 3
        for i in 0 ..< count{
            let moveArc    = self.circleAnimation(0, radius: radius, angle: CGFloat.pi * 2 * i / count)
            let rotate0    = CABasicAnimation.rotateZ(0, to: 0)
            
            let group      = CAAnimationGroup()
            group.animations = [moveArc, rotate0]
            group.duration = 0
            group.fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
            group.isRemovedOnCompletion = false
            let cardView = cardsView.subviews[i] as! CardView
            let layer = cardView.layer
            CATransaction.setCompletionBlock({
                [weak self] in
                guard let `self` = self else {
                    return
                }
                cardView.center = layer.presentation()!.position
                cardView.center.x -= self.view.frame.width
                layer.removeAnimation(forKey: "gatyaAnimation")
                UIView.animate(withDuration: 0.3, animations: {
                    cardView.center.x += self.view.frame.width
                }, completion: {
                    [weak self] _ in
                    guard let `self` = self else{
                        return
                    }
                    cardView.center.x += self.view.frame.width
                })
                
                if i == count - 1{
                    completion()
                }
            })
            layer.add(group, forKey: "gatyaAnimation")
            
            CATransaction.commit()
        }
    }

    
    private func animationFirst(_ completion: @escaping() -> ()){
        let radius = self.view.frame.size.height / 3
        let waitDuration   = 0.05 / animationSpeedRate
        let moveUpDuration = 0.5 / animationSpeedRate
        let circleDuration = 1.5 / animationSpeedRate
        let rotateDuration = 0.1 / animationSpeedRate
        let packDuration = 1.2 / animationSpeedRate
        packAnimation(packDuration){
            [weak self] in
            guard let `self` = self else{
                return
            }
            self.particleView.scene.perform(pack: self.view, completion: {})
            let count = self.RollCountOnceGatya
            for i in 0 ..< count{
                CATransaction.begin()
                let center = self.view.center
                let moveUp     = CABasicAnimation.move(moveUpDuration, to: CGPoint(x: center.x, y: center.y - radius))
                let rotate90   = CABasicAnimation.rotateZ(rotateDuration, to: CGFloat.pi / 2)
                let moveCircle = self.circleAnimation(circleDuration, radius: radius, angle: CGFloat.pi * 2)
                let moveArc    = self.circleAnimation((circleDuration * i.d) / count.d, radius: radius, angle: CGFloat.pi * 2 * i / count)
                let rotate0    = CABasicAnimation.rotateZ(rotateDuration, to: 0)
                moveUp.beginTime = waitDuration * (i + 1)
                rotate90.beginTime = moveUp.beginTime + moveUp.duration
                moveCircle.beginTime = rotate90.beginTime + rotate90.duration + waitDuration * count
                moveArc.beginTime = moveCircle.beginTime + moveCircle.duration
                rotate0.beginTime = moveArc.beginTime + moveArc.duration
                
                let group      = CAAnimationGroup()
                group.animations = [moveUp, rotate90, moveCircle, moveArc, rotate0]
                group.duration = rotate0.beginTime + rotate0.duration
                group.fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
                group.isRemovedOnCompletion = false
                let cardView = self.cardsView.subviews[i] as! CardView
                let layer = cardView.layer
                CATransaction.setCompletionBlock({
                    [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    cardView.center = layer.presentation()!.position
                    layer.removeAnimation(forKey: "gatyaAnimation")
                    if i == count - 1{
                        completion()
                    }
                })
                layer.add(group, forKey: "gatyaAnimation")
                
                CATransaction.commit()
            }
        }
    }
    
    private func animation(_ completion: @escaping () -> ()){
        if isFirstAnimation{
            isFirstAnimation = false
            animationFirst(completion)
        }else{
            animationFirst(completion)
//            animationAfterSecond(<#T##completion: () -> ()##() -> ()#>)
        }
    }
    
    private func showAllCard(_ duration: TimeInterval, completion: @escaping () -> ()){
        let frames = listCardFrame
        for (i, card) in cardsView.subviews.enumerated() {
            let comp = i == cardsView.subviews.count - 1 ? completion : nil
            UIView.animate(withDuration: duration, animations: {
                card.center = CGPoint(x: frames[i].midX, y: frames[i].midY)
            }, completion: {
                _ in
                card.center = CGPoint(x: frames[i].midX, y: frames[i].midY)
                comp?()
            })
        }
    }
    
    private func flowingAnimation(_ duration: TimeInterval, completion: @escaping () -> ()){
        for (i, card) in self.cardsView.subviews.enumerated(){
            let by = CGPoint(x: self.view.frame.width, y: 10.cf.random.randomSign)
            UIView.animate(withDuration: duration, animations: {
                card.center += by
            }, completion: {
                [weak self] _ in
                guard let `self` = self else {
                    return
                }
                card.center += by
                if i == self.cardsView.subviews.count - 1{
                    completion()
                }
            })
        }
    }
    
    private func touch(_ touches: Set<UITouch>){
        //演出中なら抜ける
        if isPerform{ return }
        
        switch currentStep {
        case .start?:
            isPerform = true
            self.particleView.scene.stopNormal()
            self.animation {
                [weak self] in
                guard let `self` = self else{
                    return
                }
                self.isPerform = false
                self.currentStep = .cardTouch
            }
        case .cardTouch?:
            //座標を取得しそこにあるノードの裏カードをひっくり返す
            //裏カードは親ビューから取り除き表カードを表示する
            //カードのレアリティによる演出をする
            //全てのカードが表向きになったらカードの一覧を表示
            for touch in touches{
                guard let card = getCard(from: touch) else{
                    return
                }
                if !card.bothSidesView.isBack {
                    return
                }
                ManageAudio.shared.playMultiple("se_card_flip.mp3")
                if card.card?.rarity == .UR{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        ManageAudio.shared.playMultiple("shakin2.mp3")
                    }
                    viewScaleAnimation(card.bothSidesView, duration: 0.9)
                }
                self.particleView.scene.perform(0.2, card: card.card!, view: card, completion: {})
                card.bothSidesView.flip(0.3){
                    [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    for c in self.cardsView.subviews as! [CardView]{
                        //裏を向いているなら
                        if c.bothSidesView.isBack{
                            return
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        self.showAllCard(0.3){
                            self.currentStep = .finish
                            self.displayButton()
                        }
                    })

                }
            }
        case .finish?:
            guard let card = getCard(from: touches.first!) else{
                return
            }
            characterDetail(card.card!)
        case .none:
            break
        case .some(_):
            break
        }
    }
    
    private func viewScaleAnimation(_ view: UIView, duration: TimeInterval){
        UIView.animate(withDuration: duration * 2 / 3, delay: 0, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform(scaleX: 3, y: 3)
        }, completion: { _ in
            UIView.animate(withDuration: duration / 3, delay: 0, options: .curveEaseIn, animations: {
                view.transform = CGAffineTransform.identity
            }, completion: nil)
        })
    }
    
    private func getCard(from touch: UITouch)-> CardView?{
        guard let view = cardsView.hitTest(touch.location(in: cardsView), with: nil) else{
            return nil
        }
        for animationCard in cardsView.subviews as! [CardView]{
            if animationCard == view{
                return animationCard
            }
        }
        return nil
    }
        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isPerform || !characterDetailView.isHidden{
            return
        }
        touch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if isPerform || !characterDetailView.isHidden{
            return
        }
        touch(touches)
    }
    
    
    private func  characterDetail(_ card: Card){
        characterDetailView.isHidden = false
        characterDetailView.card = card
    }
    
    private func displayButton(){
        let button = self.getCards.isEmpty ? self.backButton : self.okButton
        button?.isHidden = false
        button?.alpha = 0
        UIView.animate(withDuration: 0.8, animations: {
            button?.alpha = 1
        }, completion: {_ in
            button?.alpha = 1
        })
    }
    
    @IBAction func next(_ sender: Any) {
        UIView.animate(withDuration: 0.8, animations: {
            self.okButton.alpha = 0
        }, completion: {
            [weak self] _ in
            guard let `self` = self else{
                return
            }
            self.okButton.isHidden = true
        })
        
        self.flowingAnimation(0.8){
            [weak self] in
            guard let `self` = self else {
                return
            }
            self.takeOutCards()
            self.currentStep = .start
            self.packImageView.isHidden = false
            self.particleView.scene.playNormal()
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFillMode(_ input: String) -> CAMediaTimingFillMode {
	return CAMediaTimingFillMode(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFillMode(_ input: CAMediaTimingFillMode) -> String {
	return input.rawValue
}
