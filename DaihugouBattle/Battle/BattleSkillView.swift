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
    @IBOutlet weak var descriptionTextView: UITextView!{
        didSet{
            descriptionTextView.isEditable = false
        }
    }
    @IBInspectable var descriptionBackgroundColor: UIColor = .white{
        didSet{
            descriptionTextView.backgroundColor = descriptionBackgroundColor
        }
    }
    var skill: Skill?{
        didSet{
            descriptionTextView.text = skill?.description ?? ""
        }
    }
    
    @IBInspectable var textColor: UIColor = .black{
        didSet{
            descriptionTextView.textColor = textColor
        }
    }
    
    @IBInspectable var hiddenDelay: TimeInterval = 2.0
    @IBInspectable var hiddenDuration: TimeInterval = 0.2
    @IBInspectable var appearDuration: TimeInterval = 0.2
    @IBInspectable var appearDelay: TimeInterval = 0.0
    
    var animationCount: Int = 0
    func animation(_ skill: Skill){
        self.skill = skill
        
        let appearAnimation = CABasicAnimation.moveY(appearDuration, to: bounds.height / 2)
        let hiddenAnimation = CABasicAnimation.moveY(hiddenDuration, to: -bounds.height / 2)
        
        appearAnimation.beginTime = CACurrentMediaTime() + appearDelay
        appearAnimation.timingFunction = .init(name: .easeIn)
        
        hiddenAnimation.beginTime = CACurrentMediaTime() + appearDelay + appearDuration + hiddenDelay
        hiddenAnimation.timingFunction = .init(name: .easeOut)
        
        layer.removeAllAnimations()
        layer.add(appearAnimation, forKey: "appear")
        layer.add(hiddenAnimation, forKey: "hidden")
    }
}
