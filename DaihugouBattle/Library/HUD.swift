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
import RxSwift

@IBDesignable class TapableView: UIView{
    var tapGesture: UITapGestureRecognizer!
    var tapped: (()->())?
    let disposeBag = DisposeBag()
    
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

protocol HUDable where Self: UIView{
    func show()
    func show(belowSubview: UIView)
    func dismiss()
}

extension HUDable{
    func show(){
        let windows = UIApplication.shared.windows
        var w: UIWindow!
        for window in windows.reversed(){
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = window.windowLevel == UIWindow.Level.normal
            if windowOnMainScreen && windowIsVisible && windowLevelSupported{
                w = window
            }
        }
        w = w ?? UIApplication.shared.keyWindow
        
        w.addSubview(self)
        frame.origin = CGPoint.zero
        autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        isHidden = false
        frame = w.bounds
    }
    
    func show(belowSubview: UIView){
        let windows = UIApplication.shared.windows
        var w: UIWindow!
        for window in windows.reversed(){
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelSupported = window.windowLevel == UIWindow.Level.normal
            if windowOnMainScreen && windowIsVisible && windowLevelSupported{
                w = window
            }
        }
        w = w ?? UIApplication.shared.keyWindow
        
        w.insertSubview(self, belowSubview: belowSubview)
        frame.origin = CGPoint.zero
        autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        isHidden = false
        frame = w.bounds
    }
    
    func dismiss(){
        removeAllSubviews()
        removeSafelyFromSuperview()
    }
}

class HUDClosableView: TapableView, HUDable{
    override init(frame: CGRect){
        super.init(frame: frame)
        tapped = dismiss
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tapped = dismiss
    }
}

class HUDView: UIView, HUDable{
    
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
        case outOfFrameDark, outOfFrameClear, outOfFrameDarkBlur, closableDark, closableClear, closableDarkBlur, dark, darkBlur, clear
        
        func view()-> UIView{
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
            case .outOfFrameDark:
                let view = OutOfFrameCloseView(frame: .zero)
                setDarkView(view)
                return view
            case .outOfFrameClear:
                let view = OutOfFrameCloseView(frame: .zero)
                return view
            case .outOfFrameDarkBlur:
                let view = OutOfFrameCloseView(frame: .zero)
                setDarkBlurView(view)
                return view
            case .closableDark:
                let view = HUDClosableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                setDarkView(view)
                return view
            case .closableClear:
                let view = HUDClosableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                return view
            case .closableDarkBlur:
                let view = HUDClosableView(frame: .zero)
                view.tapped = {
                    HUD.shared.dismiss()
                }
                setDarkBlurView(view)
                return view
            case .dark:
                let view = HUDView(frame: .zero)
                setDarkView(view)
                return view
            case .darkBlur:
                let view = HUDView(frame: .zero)
                setDarkBlurView(view)
                return view
            case .clear:
                let view = HUDView(frame: .zero)
                return view
            }
        }
    }
    
    func show(_ maskType: MaskType = .clear){
        container = maskType.view()
        if let container = container as? HUDable{
            container.show()
        }
    }
    
    func show(_ maskType: MaskType = .clear, belowSubview: UIView){
        container = maskType.view()
        if let container = container as? HUDable{
            container.show(belowSubview: belowSubview)
        }
    }
    
    func dismiss(){
        if let container = container as? HUDable{
            container.dismiss()
        }
    }
}
