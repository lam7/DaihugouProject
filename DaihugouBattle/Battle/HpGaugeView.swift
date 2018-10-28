//
//  HpGauge.swift
//  DaihugouBattle
//
//  Created by Main on 2017/12/05.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit


fileprivate extension Int{
    /// 自身の数字を最小値未満にならないように調節する。
    ///
    /// - Parameter lowest: 最小値
    /// - Returns: 最小値以下になれば最小値を返す。それ以外は自身の数字を返す。
    func adjust(lowest: Int)-> Int{
        return self > lowest ? self : lowest
    }
    
    /// 自身の数字を最大値をこえないように調節する。
    ///
    /// - Parameter maxium: 最大値
    /// - Returns: 最大値以上になれば最大値を返す。それ以外は自身の数字を返す。
    func adjust(maximum: Int)-> Int{
        return self >= maximum ? maximum : self
    }
    
    /// 自身の数字を最小値以上、最大値以下になるように調節する。
    ///
    /// - Parameter maxium: 最大値
    /// - Returns: 最小値以下になれば最小値を返す。最大値以上になれば最大値を返す。それ以外は自身の数字を返す。
    func adjust(lowest: Int, maximum: Int)-> Int{
        let min = self.adjust(lowest: lowest)
        return min.adjust(maximum: maximum)
    }
}

/// HPゲージ
@IBDesignable class HpGaugeView: UINibView, IDAProgressViewDelegate{
    @IBOutlet weak var label: EFCountingLabel!
    @IBOutlet weak var progressView: IDAProgressView!
    private(set) var hp: Int = 0
    private(set) var maxHp: Int = 0
    
    var speed: TimeInterval = 1.0
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }
    
    private func setUp(){
        label.text = "0/0"
        progressView.delegate = self
        progressView.set(progress: 1.0)
    }
    
    ///　最大Hpをセットする
    func set(maxHp: Int){
        self.maxHp = maxHp
        if maxHp < 0{
            self.maxHp = 0
        }
        
        hp = maxHp
        
        //ラベルのテキスト表示方法の設定
        let postfixAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20) ]
        let prefixAttributes = [ NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20) ]
        let prefixString: (Int)-> String = {
            value in
            return String(format: "%d", value)
        }
        let postfixString: (Int)-> String = {
            value in
            return String(format: "/%d", maxHp)
        }
        label.attributedFormatBlock = {
            value in
            let prefix = prefixString(value.i)
            let postfix = postfixString(maxHp)
            let prefixAttr = NSMutableAttributedString(string: prefix, attributes: prefixAttributes)
            let postfixAttr = NSAttributedString(string: postfix, attributes: postfixAttributes)
            prefixAttr.append(postfixAttr)
            return prefixAttr
        }
        label.countFromCurrentValueTo(maxHp.cf)
    }
    
    
    /// hpをセットする
    /// セットされたhpに対してアニメーションさせる
    ///
    /// - Parameters:
    ///   - hp: 体力
    ///   - withDuration: アニメーションにかける時間
    ///   - completion: アニメーション完了時の処理
    func set(hp: Int, withDuration: TimeInterval, completion: (() -> ())?){
        self.hp = hp.adjust(lowest: 0, maximum: maxHp)
        label.countFromCurrentValueTo(self.hp.cf, withDuration: withDuration)
        let ratio = self.hp.cf / maxHp.cf
        progressView.set(progress: ratio, duration: withDuration, completion: completion)
    }
    
    /// hpをセットする。
    /// セットされたhpに対してアニメーションさせる。
    /// アニメーションにかける時間は'speed * 現在の体力との差'となる
    /// - Parameters:
    ///   - hp: 体力
    ///   - completion: アニメーション完了時の処理
    func set(hp: Int, completion: (() -> ())?){
        let tmp: Int = self.hp
        self.hp = hp.adjust(lowest: 0, maximum: maxHp)
        let d = TimeInterval(abs(tmp - self.hp))
        let duration: TimeInterval = d * speed
        label.countFromCurrentValueTo(self.hp.cf, withDuration: duration)
        let ratio: CGFloat = self.hp.cf / maxHp.cf
        progressView.set(progress: ratio, duration: duration, completion: completion)
    }
    
    
    func progressView(progressView: IDAProgressView, increase to: CGFloat) {
        //体力が増えるときはレイヤーの透明度をさげる
        progressView.auxiliaryLayer.opacity = 0.4
    }
    
    func didEndAnimation(of progressView: IDAProgressView) {
        //アニメーションが終わったときに下げた透明度を戻す
        progressView.auxiliaryLayer.opacity = 1
    }
    
}

