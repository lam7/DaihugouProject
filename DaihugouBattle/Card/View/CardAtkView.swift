//
//  AtkView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/05.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit


class CardAtkView: UIView{
    weak var atkLabel: EFCountingLabel!
    weak var gradientLayer: CAGradientLayer!
    var atk: Int!{
        didSet{
            atkLabel.countFromCurrentValueTo(atk.cf)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.flatRed().cgColor, UIColor.flatWhite().cgColor]
        self.layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        
        
        let atkLabel = EFCountingLabel()
        atkLabel.attributedFormatBlock = {
            value in
            return NSAttributedString(string: "\(value)")
        }
        
        self.addSubview(atkLabel)
        self.atkLabel = atkLabel
        atk = 0
        

        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }
}
