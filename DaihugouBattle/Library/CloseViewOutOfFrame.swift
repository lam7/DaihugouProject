//
//  CloseViewOutOfFrame.swift
//  DaihugouBattle
//
//  Created by main on 2019/06/02.
//  Copyright © 2019 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol ClosableView where Self: UIView{
    var closeAction: (()->())? { set get }
    func closeView()
}

extension ClosableView{
    func closeView(){
        self.isHidden = true
    }
}

class OutOfFrameCloseView: UIView, HUDable{
    let disposeBag = DisposeBag()
    weak var targetView: UIView?
    
    @discardableResult
    static func show(_ targetView: UIView?)-> OutOfFrameCloseView{
        let v = OutOfFrameCloseView()
        v.show()
        v.targetView = targetView
        v.setUpTargetView()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let t = targetView?.hitTest(point, with: event){
            return t
        }
        return self
    }
    
    func setUpTargetView() {
        self.layer.mask = targetView?.layer
        if let closableView = targetView as? ClosableView{
            closableView.closeAction = closeView
        }
         targetView.rx
            .observeWeakly(Bool.self, "isHidden")
            .flatMap({ $0.map{ Observable.just($0) } ?? Observable.empty() })
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OutOfFrameCloseView.tap(_:)))
        addGestureRecognizer(tapGesture)
        
//        setNeedsDisplay()
//        layoutIfNeeded()
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        closeView()
    }
    
    func closeView(){
        self.isHidden = true
        targetView?.isHidden = true
    }
    
    func openView(){
        self.isHidden = false
        targetView?.isHidden = false
    }
}
