//
//  OutOfFrameCloseView.swift
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

class OuterFrameClosableView: UIView{
    let disposeBag = DisposeBag()
    private var keyValueObservations = [NSKeyValueObservation]()
    private let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OuterFrameClosableView.tap(_:)))
    var targetView: UIView?{
        didSet{
            guard let targetView = self.targetView else{
                return
            }
            keyValueObservations.forEach{
                $0.invalidate()
            }
            keyValueObservations.removeAll()
            let keyValueObservation = targetView.observe(\.isHidden, options: [.new], changeHandler: { [weak self] _, value in
                guard let self = `self`,
                    let isHidden = value.newValue else{ return }
                self.isHidden = isHidden
            })
            keyValueObservations.append(keyValueObservation)

            self.isHidden = targetView.isHidden
            self.addGestureRecognizer(self.tapGesture)
            setNeedsDisplay()
            layoutIfNeeded()
        }
    }
    
    @discardableResult
    static func show(_ targetView: UIView)-> OuterFrameClosableView?{
        guard let vc = targetView.parentViewController() else{
            return nil
        }
        let v = OuterFrameClosableView(frame: vc.view.bounds)
        vc.view.addSubview(v)
        v.targetView = targetView
        v.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.8)
        return v
    }
    
    deinit{
        keyValueObservations.forEach{
            $0.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden{
            return nil
        }
        if let targetView = self.targetView{
            let f = convert(targetView.frame, to: self)
            print(f)
            if f.contains(point){
                return nil
            }
        }
        return self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let closable = targetView as? ClosableView{
            closable.closeView()
        }else{
            targetView?.isHidden = true
        }
    }
    

    override func draw(_ rect: CGRect) {
        if let targetView = self.targetView{
            let maskLayer = CAShapeLayer()
            maskLayer.bounds = self.bounds
            maskLayer.position = self.center
            let path =  UIBezierPath(rect: self.bounds)
            path.append(UIBezierPath(rect: targetView.frame))
            maskLayer.fillColor = UIColor.black.cgColor
            maskLayer.path = path.cgPath
            //            maskLayer.position = targetView.center
            // マスクのルールをeven/oddに設定する
            maskLayer.fillRule = .evenOdd
            layer.mask = maskLayer
        }
        super.draw(rect)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        if let closable = targetView as? ClosableView{
            closable.closeView()
        }else{
            targetView?.isHidden = true
        }
    }
}
