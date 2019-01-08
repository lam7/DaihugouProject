//
//  HUD.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/05.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class TapableView: UIView{
    var tapGesture: UITapGestureRecognizer!
    var tapped: (()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(TapableView.tap(_:)))
        self.tapGesture = gesture
        self.addGestureRecognizer(gesture)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer){
        tapped?()
    }
}

class HUD: NSObject{
    static var shared: HUD = HUD()
    
    var container: UIView
    
    override init() {
        container = UIView()
        super.init()
    }
    
    enum MaskType{
        case closableDark, closableClear, dark, clear
        
        fileprivate func view()-> UIView{
            switch self{
            case .closableDark:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.7003616266)
                return view
            case .closableClear:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                return view
            case .dark:
                let view = UIView(frame: .zero)
                view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.7003616266)
                return view
            case .clear:
                let view = UIView(frame: .zero)
                return view
            }
        }
    }
    
    func show(_ maskType: MaskType = .clear){
        container.removeAllSubviews()
        container.removeSafelyFromSuperview()
        container = maskType.view()
        let view = searchFrontWindow()
        view.addSubview(container)
        container.frame.origin = CGPoint.zero
        container.frame.size = view.frame.size
        container.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        container.isHidden = false
    }
    
    func dismiss(){
        container.removeAllSubviews()
        container.removeSafelyFromSuperview()
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
