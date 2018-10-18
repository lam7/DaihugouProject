//
//  BarGraphView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/28.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@IBDesignable class DeckIndexBarGraph: BarGraphView{
    var deckIndexMax: Int?
    var indexCounts: [Int : Int] = [:]{
        didSet{
            let indexCounts = self.indexCounts.sorted(by: { $0.key < $1.key })
            let max = deckIndexMax ?? indexCounts.map({$0.value}).max() ?? 1
            self.barRatings = indexCounts.map({ $0.value.cf / max.cf })
            barViews.enumerated().forEach{ i, v in
                v.barLayer.strokeColor = UIColor.green.cgColor
                v.barLayer.borderWidth = 1.0
                v.barLayer.borderColor = UIColor.white.cgColor
                v.topLabel.text = indexCounts[i].value.description
                v.bottomLabel.text = indexCounts[i].key.description
            }
        }
    }
    
    func indexCounts(from deck: Deck){
        indexCounts(from: deck.cards)
    }
    
    func indexCounts(from cards: [Card]){
        var indexCounts: [Int : Int] = [:]
        cards.map({ $0.index }).forEach({
            if indexCounts[$0] == nil{ indexCounts[$0] = 1}
            else{ indexCounts[$0]! += 1}
        })
        self.indexCounts = indexCounts
    }
}
@IBDesignable class BarGraphView: UIView{
    var barViews: [BarGraphBaseView] = []
    var spacing: CGFloat = 0.0
    var barRatings: [CGFloat] = []{
        didSet{
            if oldValue.count != barRatings.count{
                barViews.forEach{ $0.removeFromSuperview() }
                barViews = []
                var w = bounds.width
                w -= (barRatings.count.cf - 1) * spacing
                w /= barRatings.count.cf
                for (i, rate) in barRatings.enumerated(){
                    let x = i.cf * (w + spacing)
                    let f = CGRect(x: x, y: 0, width: w, height: bounds.height)
                    let v = BarGraphBaseView(frame: f)
                    addSubview(v)
                    v.barLayer.update(to: rate)
                    barViews.append(v)
                }
            }else{
                barViews.enumerated().forEach{ i, v in
                    v.barLayer.update(to: barRatings[i], duration: 0.25)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        
    }
}

class BarGraphBaseView: UIView{
    weak var topLabel: UILabel!
    weak var barView: BarGraphBaseLayerView!
    var barLayer: BarGraphBaseLayer!{
        return barView.barLayer
    }
    weak var bottomLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let w = bounds.width
        let h = bounds.height * 0.15
        let topLabel = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
        topLabel.textAlignment = .center
        topLabel.adjustsFontSizeToFitWidth = true
        addSubview(topLabel)
        self.topLabel = topLabel
        
        let bottomLabel = UILabel(frame: CGRect(x: 0, y: bounds.height - h, width: w, height: h))
        bottomLabel.textAlignment = .center
        bottomLabel.adjustsFontSizeToFitWidth = true
        addSubview(bottomLabel)
        self.bottomLabel = bottomLabel
        
        let barView = BarGraphBaseLayerView(frame: CGRect(x: 0, y: h, width: w, height: bounds.height - h * 2))
        addSubview(barView)
        self.barView = barView
    }
}

class BarGraphBaseLayerView: UIView{
    var barLayer: BarGraphBaseLayer!
    override var frame: CGRect{
        didSet{
            if barLayer != nil{
                barLayer.frame = bounds
                dump(barLayer.frame)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let l = BarGraphBaseLayer()
        layer.addSublayer(l)
        self.barLayer = l
        l.frame = bounds
    }
}
class BarGraphBaseLayer: CAShapeLayer{
    override var frame: CGRect{
        didSet{
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.width / 2, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: 0))
            path.lineWidth = frame.width
            self.lineWidth = frame.width
            self.path = path.cgPath
        }
    }
    
    func update(to ratio: CGFloat, duration: CFTimeInterval = 0.25, completion: (() -> ())? = nil) {
//        dump(frame)
        CATransaction.begin()
        strokeEnd = ratio
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.toValue = ratio
        CATransaction.setCompletionBlock({
            self.strokeEnd = ratio
            completion?()
        })
        add(animation, forKey: "BarGraphAnimation")
        CATransaction.commit()
    }
}
