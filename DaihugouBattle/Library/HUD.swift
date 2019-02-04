//
//  HUD.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/05.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@IBDesignable class TapableView: UIView{
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
    
    static var container: UIView{
        return shared.container
    }
    
    static func show(_ maskType: MaskType = .clear){
        shared.show(maskType)
    }
    
    static func show(_ maskType: MaskType = .clear, belowSubview: UIView){
        shared.show(maskType, belowSubview: belowSubview)
    }
    
    static func dismiss(){
        shared.dismiss()
    }
    
    override init() {
        container = UIView()
        super.init()
    }
    
    enum MaskType{
        case closableDark, closableClear, closableDarkBlur, dark, darkBlur, clear
        
        fileprivate func view()-> UIView{
            func setDarkView(_ view: UIView){
                view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.7003616266)
            }
            
            func setDarkBlurView(_ view: UIView){
                let blur = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView(effect: blur)
                effectView.snp.makeConstraints{ make in
                    make.size.equalTo(view)
                    make.top.equalTo(view)
                    make.leading.equalTo(view)
                }
                view.addSubview(effectView)
            }
            
            switch self{
            case .closableDark:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                setDarkView(view)
                return view
            case .closableClear:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                return view
            case .closableDarkBlur:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                setDarkBlurView(view)
                return view
            case .dark:
                let view = UIView(frame: .zero)
                setDarkView(view)
                return view
            case .darkBlur:
                let view = TapableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                setDarkBlurView(view)
                return view
            case .clear:
                let view = UIView(frame: .zero)
                return view
            }
        }
    }
    
    private func clearContainer(){
        container.removeAllSubviews()
        container.removeSafelyFromSuperview()
    }
    
    private func setContainer(_ window: UIWindow){
        container.frame.origin = CGPoint.zero
        container.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        container.isHidden = false
    }
    
    func show(_ maskType: MaskType = .clear){
        clearContainer()
        let window = searchFrontWindow()
        container = maskType.view()
        window.addSubview(container)
        setContainer(window)
    }
    
    func show(_ maskType: MaskType = .clear, belowSubview: UIView){
        clearContainer()
        let window = searchFrontWindow()
        container = maskType.view()
        window.insertSubview(container, belowSubview: belowSubview)
        setContainer(window)
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
