//
//  NowLoadingView.swift
//  DaihugouBattle
//
//  Created by main on 2020/01/20.
//  Copyright © 2020 Main. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class NowLoadingView: NSObject{
    
    private static let shared = NowLoadingView()
    var lotAnimationView: AnimationView!
    var backgroundView: UIView!
    
    override init() {
        super.init()
        setUp()
    }
    
    private func setUp(){
        let frame = UIScreen.main.bounds
        let path = Bundle.main.path(forResource: "nowloading", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let data = try! Data(contentsOf: url)
        let v = AnimationView(data: data)
        let height = frame.height / 3
        let width = frame.width / 3
        v.frame = CGRect(x: frame.width - width - 20, y: frame.height - height - 10, width: width, height: height)
        v.contentMode = .scaleAspectFit
        v.loopMode = .loop
        lotAnimationView = v
        
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.6023327465)
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

