//
//  HUD.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/05.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class HUD: NSObject{
    static var shared: HUD = HUD()
    
    var container: UIView!
    
    override init() {
        super.init()
        container = UIView(frame: UIScreen.main.bounds)
    }
    
    func show(){
        let view = searchFrontWindow()
        
        if container.superview != nil{
            container.removeFromSuperview()
        }
        view.rootViewController!.view.addSubview(container)
        container.frame.origin = CGPoint.zero
        container.frame.size = view.frame.size
        container.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        container.isHidden = false
    }
    
    func hide(){
        container.isHidden = true
    }
    
    func hideAndClear(){
        container.subviews.forEach({ $0.removeFromSuperview() })
        hide()
    }
    
    
    ///表示されているWindowの中で最前面で、アラートでないものを返す
    private func searchFrontWindow()-> UIWindow{
        let windows = UIApplication.shared.windows
        for window in windows.reversed(){
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = window.windowLevel == UIWindow.Level.normal
            if windowOnMainScreen && windowIsVisible && windowLevelSupported{
                return window
            }
        }
        //ここに来るかどうかは微妙
        return UIApplication.shared.keyWindow!
    }
}
