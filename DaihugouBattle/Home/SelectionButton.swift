//
//  SelectionButton.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/19.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class SelectionButton: UIButton{
    @IBInspectable var backgroundGradientColor0: UIColor? = nil
    @IBInspectable var backgroundGradientColor1: UIColor? = nil
    @IBInspectable var backgroundGradientColor2: UIColor? = nil
    @IBInspectable var backgroundGradientColor3: UIColor? = nil
    @IBInspectable var backgroundGradientColor4: UIColor? = nil
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0
    
    
    weak var gradientLayer: CAGradientLayer!{
        didSet{
            gradientLayer.frame = bounds
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: bounds.width, y: 0)
        
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
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateGradientColors()
        
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
    }
    
    func updateGradientColors(){
        let colors = [
            backgroundGradientColor0, backgroundGradientColor1,
            backgroundGradientColor2, backgroundGradientColor3,
            backgroundGradientColor4].compactMap({ $0 })
        gradientLayer.colors = colors.map({ $0.cgColor })
    }
}
