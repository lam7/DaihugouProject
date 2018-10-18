//
//  BattleSkillView.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/05.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BattleSkillView: UINibView{
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBInspectable var descriptionBackgroundColor: UIColor = .white{
        didSet{
            descriptionTextView.backgroundColor = descriptionBackgroundColor
        }
    }
    var card: Card?{
        didSet{
            descriptionTextView.text = card?.skill.description ?? ""
        }
    }
    
    @IBInspectable var textColor: UIColor = .black{
        didSet{
            descriptionTextView.textColor = textColor
        }
    }
    @IBInspectable var hiddenDuration: TimeInterval = 0.3
    @IBInspectable var hiddenDelay: TimeInterval = 2.0
    @IBInspectable var appearDuratoin: TimeInterval = 0.3
    @IBInspectable var appearDelay: TimeInterval = 0.0
    
    
    func animation(_ card: Card, completion: @escaping () -> ()){
        self.card = card
        appearAnimation(appearDuratoin, delay: appearDelay, completion: {
            self.hiddenAnimation(self.hiddenDuration,  delay: self.hiddenDelay,completion: completion)
        })
    }
    func hiddenAnimation(_ duration: TimeInterval, delay: TimeInterval = 0.0, completion: (() -> ())?){
        let p = CGPoint(x: frame.minX, y: frame.minY - frame.height)
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.frame.origin = p
        }, completion: { _ in
            self.frame.origin = p
            completion?()
        })
    }
    
    func appearAnimation(_ duration: TimeInterval, delay: TimeInterval = 0.0, completion: (() -> ())?){
        let p = CGPoint(x: frame.minX, y: frame.minY + frame.height)
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.frame.origin = p
        }, completion: { _ in
            self.frame.origin = p
            completion?()
        })
    }
}
