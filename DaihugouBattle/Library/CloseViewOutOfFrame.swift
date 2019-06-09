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
}

class OutOfFrameCloseView: ClipFullScreenView, HUDable{
    let disposeBag = DisposeBag()
    
    override var isHidden: Bool{
        didSet{
            if isHidden{
                closeView()
            }else{
                openView()
            }
        }
    }
    
    override func setUpTargetView() {
        super.setUpTargetView()
        if let closableView = targetView as? ClosableView{
            closableView.closeAction = closeView
        }
        targetView.rx
            .observe(Bool.self, "isHidden")
            .flatMap({ $0.map{ Observable.just($0) } ?? Observable.empty() })
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OutOfFrameCloseView.tap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        closeView()
    }
    
    func closeView(){
        self.isHidden = true
        targetView.isHidden = true
    }
    
    func openView(){
        self.isHidden = false
        targetView.isHidden = false
    }
}


class ClipFullScreenView: UIView{
    ///このViewの領域を切り抜く
    weak var targetView: UIView!{
        didSet{
            setUpTargetView()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if targetView.hitTest(point, with: event) != nil{
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    func setUpTargetView(){
        self.layer.mask = targetView.layer
        setNeedsDisplay()
        layoutIfNeeded()
    }
}
