//
//  Extension_UIViewAnimate.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/16.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    static func animateOpenWindow(_ view: UIView, height: CGFloat = 1.0, durationX: TimeInterval = 0.15, durationY: TimeInterval = 0.45, completion: (() -> ())? = nil){
        let frame = view.frame
        let height : CGFloat = 1.0
        let scaleX: CGFloat = 1.0 / frame.height
        let scaleY: CGFloat = height / frame.height
        
        view.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        UIView.animate(withDuration: durationX, animations: {
            let transform = view.transform.concatenating(CGAffineTransform(scaleX: 1 / scaleX, y: 1))
            view.transform = transform
        }, completion: { _ in
            UIView.animate(withDuration: durationY, animations: {
                let transform = view.transform.concatenating(CGAffineTransform(scaleX: 1, y: 1 / scaleY))
                view.transform = transform
            }, completion: { _ in
                completion?()
            })
        })
    }
    
    static func animateCloseWindow(_ view: UIView, height: CGFloat = 1.0, durationX: TimeInterval = 0.1, durationY: TimeInterval = 0.2, completion: (() -> ())? = nil){
        let frame = view.frame
        let height: CGFloat = 1.0
        let scaleX: CGFloat = 1.0 / frame.height
        let scaleY: CGFloat = height / frame.height
        
        UIView.animate(withDuration: durationY, animations: {
            let transform = view.transform.concatenating(CGAffineTransform(scaleX: 1, y: scaleY))
            view.transform = transform
        }, completion: { _ in
            UIView.animate(withDuration: durationX, animations: {
                let transform = view.transform.concatenating(CGAffineTransform(scaleX: scaleX, y: 1))
                view.transform = transform
            }, completion: { _ in
                completion?()
            })
        })
        
    }
}
