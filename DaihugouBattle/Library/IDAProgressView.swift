//
//  IDAProgressView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/1/24.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension CATransaction{
    static func transactionDisableActions(_ block: () -> ()){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        block()
        CATransaction.commit()
    }
}
///　プログラスが増減した時にアニメーションをつける
///　ゲームなのでダメージを受けた時、受けたダメージ分だけ赤くなって減っていくあれ
/// Increase and Decrease Animation Progress View
@IBDesignable class IDAProgressView: UIView, UITableViewDelegate{
    ///　メインバーの進歩率(0.0 - 1.0)
    private(set) var progress: CGFloat = 1.0
    
    /// 0.0から1.0までアニメーションするのにかかる時間
    ///
    /// これを基準として現在から指定のprogressまでの時間を算出する
    var speed: CFTimeInterval = 1.0
    
    /// ゲージが向かう先を示すレイヤーがアニメーション時間
    var auxiliaryAnimationDuration: CFTimeInterval = 0.05
    
    /// ゲージがアニメーションする際に使われるキー
    static let animationKey: String = "animateStrokeEnd"
    
    /// メインバーの幅
    private var lineWidth: CGFloat = 0{
        didSet {
            progressLayer.lineWidth = lineWidth
            auxiliaryLayer.lineWidth = lineWidth
            guideLayer.lineWidth = lineWidth
        }
    }
    
    ///　メインバーの端をどのように描画するか
    ///　https://docs-assets.developer.apple.com/published/a0a82ebdd4/linecaps_objectivec_df8aae67-3aab-4940-a9c5-33bc8559d3f6.gif
    @IBInspectable open var lineCap: String = kCALineCapButt {
        didSet {
            progressLayer.lineCap = lineCap
            auxiliaryLayer.lineCap = lineCap
            guideLayer.lineCap = lineCap
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0{
        didSet{
            progressLayer.cornerRadius = cornerRadius
            auxiliaryLayer.cornerRadius = cornerRadius
            guideLayer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable open var maskToBounds: Bool = false{
        didSet{
            progressLayer.masksToBounds = maskToBounds
            auxiliaryLayer.masksToBounds = maskToBounds
            guideLayer.masksToBounds = maskToBounds
        }
    }
    
    ///auxiliaryLayerが増加するときの色
    @IBInspectable open var increaseColor: UIColor = .green
    
    ///auxiliaryLayerが減少するときの色
    @IBInspectable open var decreaseColor: UIColor = .red
    
    /// レイヤーの形を変動するためのパス
    ///
    /// このパス上をアニメーションする
    open var path: CGPath?{
        didSet {
            progressLayer.path = path
            auxiliaryLayer.path = path
            guideLayer.path = path
        }
    }
    
    open var delegate: IDAProgressViewDelegate?
    
    /// メインとなるレイヤー
    ///
    /// 一番上に表示される
    private(set) lazy var progressLayer: IDAShapeLayer = {
        let progressLayer = IDAShapeLayer()
        progressLayer.frame = bounds
        progressLayer.strokeColor = UIColor.green.cgColor
        return progressLayer
    }()
    
    /// progressLayerの補助となるレイヤー
    ///
    /// progressLayerの下に表示される
    /// - progressが減った時、アニメーションをする
    /// - progressが増えた時、アニメーションせずに一気に終了値まで行く
    private(set) lazy var auxiliaryLayer: IDAShapeLayer = {
        let auxiliaryLayer = IDAShapeLayer()
        auxiliaryLayer.frame = bounds
        return auxiliaryLayer
    }()
    
    /// ゲージの全表示域を表示するレイヤー
    ///
    /// auxiliaryLayerの下に表示される
    private(set) lazy var guideLayer: IDAShapeLayer = {
        let guideLayer = IDAShapeLayer()
        guideLayer.frame = bounds
        guideLayer.strokeColor = UIColor.black.cgColor
        return guideLayer
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: frame.height / 2))
        bezierPath.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        path = bezierPath.cgPath
        lineWidth = frame.height
        
        layer.addSublayer(guideLayer)
        layer.addSublayer(auxiliaryLayer)
        layer.addSublayer(progressLayer)
    }
    
    /// 進歩率をセットする
    /// その際，アニメーションを指定秒数でする
    ///
    /// - 増加する際はdelegate.progressView(progressView, increase)がアニメーション処理の前に呼ばれる
    /// - 減少する際はdelegate.progressView(progressView, decrease)がアニメーション処理の前に呼ばれる
    /// - アニメーションが完了した際はdelegate.didEneAnimation(progressView)が呼ばれる
    public func set(progress: CGFloat, duration: CFTimeInterval = 0, completion: (() -> ())? = nil){
        let block = {
            self.progress = progress
            self.delegate?.didEndAnimation?(of: self)
            completion?()
        }
        let clipProgress = max(min(progress, 1.0), 0.0)
        if self.progress <= clipProgress{
            //増加する場合
            CATransaction.transactionDisableActions{
                auxiliaryLayer.strokeColor = increaseColor.cgColor
            }
            delegate?.progressView?(progressView: self, increase: progress)
            progressLayer.update(to: clipProgress, duration: duration, completion: block)
            auxiliaryLayer.update(to: clipProgress, duration: auxiliaryAnimationDuration)
        }else{
            //減少する場合
            CATransaction.transactionDisableActions{
                auxiliaryLayer.strokeColor = decreaseColor.cgColor
            }
            delegate?.progressView?(progressView: self, decrease: progress)
            progressLayer.update(to: clipProgress, duration: auxiliaryAnimationDuration)
            auxiliaryLayer.update(to: clipProgress, duration: duration, completion: block)
        }
    }
    
    /// 進歩率をセットする
    /// その際，アニメーションを'speed * abs(progress - self.progress)'秒でする
    ///
    /// - 増加する際はdelegate.progressView(progressView, increase)がアニメーション処理の前に呼ばれる
    /// - 減少する際はdelegate.progressView(progressView, decrease)がアニメーション処理の前に呼ばれる
    /// - アニメーションが完了した際はdelegate.didEneAnimation(progressView)が呼ばれる
    public func set(progress: CGFloat, completion: (() -> ())? = nil){
        let clipProgress = max(min(progress, 1.0), 0.0)
        let duration = CFTimeInterval(abs(clipProgress - self.progress)) * speed
        set(progress: progress, duration: duration, completion: completion)
    }
}

@objc protocol IDAProgressViewDelegate {
    @objc optional func progressView(progressView: IDAProgressView, increase to: CGFloat)
    @objc optional func progressView(progressView: IDAProgressView, decrease to: CGFloat)
    @objc optional func didEndAnimation(of progressView: IDAProgressView)
}

class IDAShapeLayer: CAShapeLayer {
    func update(to progress: CGFloat, duration: CFTimeInterval, completion: (() -> ())? = nil) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.toValue = progress
        CATransaction.setCompletionBlock({
            self.strokeEnd = progress
            completion?()
        })
        add(animation, forKey: IDAProgressView.animationKey)
        CATransaction.commit()
    }
}


