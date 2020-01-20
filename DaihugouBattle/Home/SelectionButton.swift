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
    @IBInspectable var gradientColor0: UIColor? = nil
    @IBInspectable var gradientColor1: UIColor? = nil
    @IBInspectable var gradientColor2: UIColor? = nil
    @IBInspectable var gradientColor3: UIColor? = nil
    @IBInspectable var gradientColor4: UIColor? = nil
    @IBInspectable var gradientLocation0: Float = 0
    @IBInspectable var gradientLocation1: Float = 0.25
    @IBInspectable var gradientLocation2: Float = 0.5
    @IBInspectable var gradientLocation3: Float = 0.75
    @IBInspectable var gradientLocation4: Float = 1.0
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderColor: UIColor? = nil
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var gradientStartPoint: CGPoint = CGPoint(x: 0, y: 0.5)
    @IBInspectable var gradientEndPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    weak var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
    
    override func draw(_ rect: CGRect) {
        updateGradientColors()
        updateLayerProperty()

        super.draw(rect)
    }
    
    func updateLayerProperty(){
        layer.borderWidth = borderWidth
        var cornerRadius = self.cornerRadius
        if cornerRadius < 0{
            let m = min(layer.bounds.width, layer.bounds.height)
            cornerRadius = m / 2
        }
        layer.cornerRadius = cornerRadius
        if let borderColor = self.borderColor{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    func updateGradientColors(){
        let colors = [
            gradientColor0, gradientColor1,
            gradientColor2, gradientColor3,
            gradientColor4].compactMap{ $0 }
        print(colors)

        gradientLayer.colors = colors.map({ $0.cgColor })
        gradientLayer.startPoint = gradientStartPoint
        gradientLayer.endPoint = gradientEndPoint
        gradientLayer.frame = bounds
        
        let locations = [
            gradientLocation0, gradientLocation1,
            gradientLocation2, gradientLocation3,
            gradientLocation4
            ][0..<colors.count].map{ NSNumber(value: $0) }
        gradientLayer.locations = locations
    }
    
    enum Color {
        case blue, red, clear
    }
    
    func updateColor(_ color: Color) {
        switch color {
        case .blue:
            updateBlueColor()
        case .red:
            updateRedColor()
        case .clear:
            updateClearColor()
        }
        
    }
    
    func updateBlueColor() {
        
    }
    func updateRedColor() {
        
    }
    func updateClearColor() {
        
    }
}
