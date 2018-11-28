//
//  LoadingView.swift
//  Daihugou
//
//  Created by Main on 2017/06/18.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import Chameleon
import Lottie


extension LOTAnimationView{
    convenience init(data: Data){
        let animationJSON = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        self.init(json: animationJSON as! Dictionary)
    }
    
    func setAnimation(data: Data){
        let animationJSON = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        self.setAnimation(json: animationJSON as! Dictionary)
    }
}

class LoadingView: NSObject{
    
    private static let shared: LoadingView = LoadingView()
    var lotAnimationView: LOTAnimationView!
    var backgroundView: UIView!
    
    override init() {
        super.init()
        setUp()
    }
    
    private func setUp(){
        let frame = UIScreen.main.bounds
        
        let v = LOTAnimationView(data: DataRealm.get(dataNamed: "loading1.json")!)
        let height = frame.height / 3
        let width = frame.width / 3
        v.frame = CGRect(x: frame.width - width - 10, y: frame.height - height - 10, width: width, height: height)
        v.contentMode = .scaleAspectFit
        v.loopAnimation = true
        lotAnimationView = v
        
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = .flatBlue()
        backgroundView.layer.zPosition = CGFloat.leastNormalMagnitude
        backgroundView.addSubview(lotAnimationView)
    }
    
    static func show(){
        guard let window = UIApplication.shared.keyWindow else{
            return
        }
        window.addSubview(shared.backgroundView)
        shared.lotAnimationView.play()
    }
    
    static func hide(delay: TimeInterval = 0){
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {
            _ in
            print("hideeeeee")
            shared.backgroundView.removeSafelyFromSuperview()
            shared.lotAnimationView.stop()
        }).fire()
    }
}

class Circlelayer : CAShapeLayer {
    
    var onLight : Bool = true
    fileprivate var count : Int = 1
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        //背景
        let c = UIColor.clear
        ctx.setFillColor(c.cgColor)
        ctx.addRect(self.bounds)
        ctx.drawPath(using: .fill)
        
        //center circle
        ctx.addArc(center: CGPoint(x: self.bounds.midX, y:self.bounds.midY), radius: 8, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        ctx.closePath()
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.drawPath(using: .fill)
    }
    
}
