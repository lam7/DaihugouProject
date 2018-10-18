//
//  BothSidesView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/20.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

class BothSidesView: UIView{
    var frontView: UIView!
    var backView: UIView!
    
    private(set) var isBack = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        frontView = UIView(frame: bounds)
        backView = UIView(frame: bounds)
        frontView.backgroundColor = .clear
        backView.backgroundColor = .clear
        addSubview(frontView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event){
            return self
        }
        return nil
    }
    
    func flip(_ duration: TimeInterval, options: UIView.AnimationOptions = UIView.AnimationOptions.transitionFlipFromRight, completion: (() -> ())? = nil) {
        let toView = isBack ? frontView : backView
        let fromView = isBack ? backView : frontView
        self.isBack = !self.isBack

        UIView.transition(from: fromView!, to: toView!, duration: duration, options: options){
            _ in
            completion?()
        }
    }
    
    func flip(_ duration: TimeInterval, isFront: Bool, options: UIView.AnimationOptions = UIView.AnimationOptions.transitionFlipFromRight, completion: (() -> ())? = nil){
        let toView = isFront ? frontView : backView
        let fromView = isFront ? backView : frontView
        self.isBack = !isFront
        
        UIView.transition(from: fromView!, to: toView!, duration: duration, options: options){
            _ in
            completion?()
        }
    }
}
