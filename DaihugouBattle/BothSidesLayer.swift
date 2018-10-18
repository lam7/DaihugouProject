//
//  BothSidesLayer.swift
//  DaihugouBattle
//
//  Created by Main on 2018/01/10.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class BothSideLayer: CALayer{
    let front = CALayer()
    let back = CALayer()
    var isFliped: Bool = false
    
    override init() {
        super.init()
        setUp()
    }
    
    override init(layer: Any) {
        super.init()
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        front.isDoubleSided = false
        back.isDoubleSided = false
        
        back.setValue(CGFloat.pi, forKey: "transform.rotation.y")
        
        addSublayer(back)
        addSublayer(front)
    }
    
    
    override func display() {
        super.display()
        front.frame = bounds
        back.frame = bounds
    }
    
    enum FlipOption{
        case FromLeft, FromRight
    }
    
    func flip(_ duration: TimeInterval){
        isFliped = !isFliped
        
        let anim = CABasicAnimation(keyPath: "transform.rotation.y")
        anim.fromValue = CGFloat.pi
    }
}
