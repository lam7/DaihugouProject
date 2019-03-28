//
//  FrameLayer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/19.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class FrameLayer: CALayer{
    var topLayer: CALayer!
    var downLayer: CALayer!
    var leftLayer: CALayer!
    var rightLayer: CALayer!
    var lineWidth: CGFloat!{
        didSet{
            topLayer.frame = CGRect(x: -lineWidth / 2, y: -lineWidth / 2, width: frame.width + lineWidth, height: lineWidth)
            downLayer.frame = CGRect(x: -lineWidth / 2, y: frame.height - lineWidth / 2, width: frame.width + lineWidth, height: lineWidth)
            leftLayer.frame = CGRect(x: -lineWidth / 2, y: 0, width: lineWidth, height: frame.height)
            rightLayer.frame = CGRect(x: frame.width - lineWidth / 2, y: 0, width: lineWidth, height: frame.height)
        }
    }
    
    var color: CGColor!{
        didSet{
            let layers = [topLayer, downLayer, leftLayer, rightLayer]
            layers.forEach({ $0?.backgroundColor = color })
        }
    }
    
    override init() {
        super.init()
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        topLayer = CALayer()
        downLayer = CALayer()
        leftLayer = CALayer()
        rightLayer = CALayer()
        color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        lineWidth = 1.0
        let layers = [topLayer, downLayer, leftLayer, rightLayer]
        layers.forEach({ self.addSublayer($0!) })
        backgroundColor = UIColor.clear.cgColor
    }
}
