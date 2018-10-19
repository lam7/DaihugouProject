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

class BarGraphView: UIStackView{
    var barViews: [BarGraphBaseView] = []
    
    var barRatings: [CGFloat] = []{
        didSet{
            setNeedsDisplay()
            layoutIfNeeded()
            if oldValue.count != barRatings.count{
                barViews.forEach{ $0.removeFromSuperview() }
                barViews = []
                let w = self.bounds.width / barRatings.count.cf
                for rate in barRatings{
                    let v = BarGraphBaseView()
                    addArrangedSubview(v)
                    v.snp.makeConstraints{ make in
                        make.height.equalTo(self)
                        make.width.equalTo(w)
                        make.centerY.equalTo(self)
                    }
                    self.barViews.append(v)
                    v.barLayer.update(to: rate)
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    
    private func setUp(){
        alignment = .top
        axis = .horizontal
        distribution = .equalSpacing
    }
}

class BarGraphBaseView: UINibView{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var barView: BarGraphBaseLayerView!
    var barLayer: BarGraphBaseLayer{
        return barView.layer as! BarGraphBaseLayer
    }
    @IBOutlet weak var bottomLabel: UILabel!
}

class BarGraphBaseLayerView: UIView{
    override class var layerClass : AnyClass {
        return BarGraphBaseLayer.self
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width / 2, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width / 2, y: 0))
        path.lineWidth = frame.width
        (layer as! BarGraphBaseLayer).lineWidth = frame.width
        (layer as! BarGraphBaseLayer).path = path.cgPath
    }
}
class BarGraphBaseLayer: CAShapeLayer{
    func update(to ratio: CGFloat, duration: CFTimeInterval = 0.25, completion: (() -> ())? = nil) {
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
