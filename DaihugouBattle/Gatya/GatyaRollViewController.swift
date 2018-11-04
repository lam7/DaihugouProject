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
import SwiftyGif



class GatyaRollViewController: UIViewController{
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var characterDetailView: PossessionCardDetailView!
    @IBOutlet weak var cardsView: UIView!
    @IBOutlet weak var cardOriginalView: UIView!
    @IBOutlet weak var packImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var particleView: GatyaParticleView!
    @IBOutlet weak var packEffectImageView: UIImageView!
    
    var gatya: Gatya!
    
    var createFrontView: ((_ frame: CGRect) -> (UIView))?
    var createBackView: ((_ frame: CGRect) -> (UIView))?
    var updateFrontView: ((_ view: UIView, _ card: Card) -> ())?
    var updateBackView: ((_ view: UIView, _ card: Card) -> ())?
    private var getCards: [Card]!
    private var animationCardViews: [CardView] = []
    private var selectedCard: Card?
    private let RollCountOnceGatya = 8
    private var isPerform: Bool!
    private var currentStep: AnimationStep!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = DataRealm.get(imageNamed: "gatyaStandartBackground.png")
        particleView.scene.setUpNormalParticle()

        if let packImage = DataRealm.get(gifNamed: "gatya_open1.gif"){
            packEffectImageView.loopCount = 1
            
            packEffectImageView.setGifImage(packImage)
        }
        
        createCardView()
    }
    
    private func createCardView(){
        //-TODO: ガチャの種類によりカードの裏面や背景を変えたりする
        let b = cardOriginalView.bounds
        for _ in (0 ..< RollCountOnceGatya).reversed(){
            let cardView = CardView(frame: b)
            self.animationCardViews.append(cardView)
            self.cardsView.addSubview(cardView)
//            switch gatya.gatyaType.id{
//                default: break
//            }
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        LoadingView.show()
        isPerform = true
        
        ManageAudio.shared.addAudioFromRealm("CardFlip.wav", audioType: .se)
        
        packImageView.image = DataRealm.get(imageNamed: "gatyaStandart.png")
        print("gatyaRoll")
        gatya.roll(){
            
            cards, error in
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardsView.removeAllSubviews()
        getCards = []
        selectedCard = nil
        animationCardViews = []
        ManageAudio.shared.removeAudio("CardFlip.wav")
    }
    
    private func present(_ error: Error, completion: (() -> ())!){
        let errorAlart = UIAlertController(title: "エラー", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "前の画面に戻る", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
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
            animationCardViews[i].card = card
            animationCardViews[i].layer.removeAllAnimations()
            animationCardViews[i].center = cardOriginalView.center
            animationCardViews[i].bothSidesView.flip(0, isFront: false)
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
        CATransaction.setCompletionBlock{
            completion()
            CATransaction.begin()
            let moveAnimation = CABasicAnimation.move(0.8, by: CGPoint(x: 30, y: 8))
            let hiddenAnimation = CABasicAnimation.hidden(0.8, to: true)
            CATransaction.setCompletionBlock{
                self.packImageView.layer.removeAllAnimations()
                self.packImageView.isHidden = true
            }
            self.packImageView.layer.add(moveAnimation, forKey: "moveAnimation")
            self.packImageView.layer.add(hiddenAnimation, forKey: "hiddenAnimation")
            CATransaction.commit()
        }
        packImageView.layer.add(ecAnimation, forKey: "ecAnimation")
        CATransaction.commit()
        
        packEffectImageView.animationDuration = 0.8
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
    
    
    private func animation(_ completion: @escaping () -> ()){
        let radius = self.view.frame.size.height / 3
        let waitDuration   = 0.05
        let moveUpDuration = 0.5
        let circleDuration = 1.5
        let rotateDuration = 0.1
        packAnimation(1.2){
            self.particleView.scene.perform(pack: self.view, completion: {})
            let count = self.animationCardViews.count
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
                let layer = self.animationCardViews[i].layer
                CATransaction.setCompletionBlock({
                    [weak self] in
                    guard let `self` = self,
                        let v = self.animationCardViews[safe: i] else {
                        return
                    }
                    v.center = layer.presentation()!.position
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
    
    private func showAllCard(_ duration: TimeInterval, completion: @escaping () -> ()){

        let frames = listCardFrame
        for (i, card) in animationCardViews.enumerated() {
            let comp = i == animationCardViews.count - 1 ? completion : nil
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
        for (i, card) in self.animationCardViews.enumerated(){
            let by = CGPoint(x: self.view.frame.width, y: 10.cf.random.randomSign)
            UIView.animate(withDuration: duration, animations: {
                card.center += by
            }, completion: {
                _ in
                card.center += by
                if i == self.animationCardViews.count - 1{
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
                ManageAudio.shared.play("CardFlip.wav")
                self.particleView.scene.perform(0.2, card: card.card!, view: card, completion: {})
                card.bothSidesView.flip(0.3){
                    [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    for c in self.animationCardViews{
                        //裏を向いているなら
                        if c.bothSidesView.isBack{
                            return
                        }
                    }
                    
                    self.showAllCard(0.3){
                        self.currentStep = .finish
                        self.displayButton()
                    }
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
    
    private func getCard(from touch: UITouch)-> CardView?{
        guard let view = cardsView.hitTest(touch.location(in: cardsView), with: nil) else{
            return nil
        }
        for animationCard in animationCardViews{
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
        }, completion: {_ in
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
