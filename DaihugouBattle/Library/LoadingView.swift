//
//  LoadingView.swift
//  Daihugou
//
//  Created by Main on 2017/06/18.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit
import Lottie


extension Animation{
    static func data(_ data: Data)-> Animation?{
        do {
            /// Decode animation.
            let animation = try JSONDecoder().decode(Animation.self, from: data)
            return animation
        } catch {
            /// Decoding error.
            return nil
        }
    }
}
extension AnimationView{
    convenience init(data: Data?){
        guard let data = data else {
            self.init()
            return
        }
        let animation = Animation.data(data)
        self.init(animation: animation)
    }
}

class LoadingView: NSObject{
    
    private static let shared: LoadingView = LoadingView()
    var lotAnimationView: AnimationView!
    var backgroundView: UIView!
    
    override init() {
        super.init()
        setUp()
    }
    
    private func setUp(){
        let frame = UIScreen.main.bounds
        
        let v = AnimationView(data: DataRealm.get(dataNamed: "loading1.json"))
        let height = frame.height / 3
        let width = frame.width / 3
        v.frame = CGRect(x: frame.width - width - 10, y: frame.height - height - 10, width: width, height: height)
        v.contentMode = .scaleAspectFit
        v.loopMode = .loop
        lotAnimationView = v
        
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        backgroundView.layer.zPosition = CGFloat.leastNormalMagnitude
        backgroundView.addSubview(lotAnimationView)
    }
    
    static func show(){
        HUD.show()
        HUD.container.addSubview(shared.backgroundView)
        shared.lotAnimationView.play()
    }
    
    static func hide(delay: TimeInterval = 0){
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {
            _ in
            shared.backgroundView.removeSafelyFromSuperview()
            shared.lotAnimationView.stop()
            HUD.dismiss()
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
