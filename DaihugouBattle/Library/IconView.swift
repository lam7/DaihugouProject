//
//  IconView.swift
//  DaihugouBattle
//
//  Created by main on 2018/11/01.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class PCIconLayer: CALayer
{
    
    @NSManaged var fraction : CGFloat
    
    override init()
    {
        super.init()
        fraction = 0.0
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
        
        if let layer = layer as? PCIconLayer
        {
            fraction = layer.fraction
        }
        
    }
    
    
    override class func needsDisplay(forKey key: String) -> Bool
    {
        if key == "fraction"
        {
            return true
        }
        
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction?
    {
        if event == "fraction"
        {
            let animation = CABasicAnimation.init(keyPath: event)
            animation.fromValue = presentation()?.value(forKey: event)
            return animation
        }
        return super.action(forKey: event)
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}


class PCIconView: UIView{
    override class var layerClass : AnyClass{
        return PCIconLayer.self
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
        layer.contentsScale = UIScreen.main.scale
        layer.setNeedsDisplay()
    }
    
    func animateTo(_ duration: TimeInterval = 0.5)
    {
        let timing : CAMediaTimingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        let theAnimation = CABasicAnimation(keyPath: "fraction")
        theAnimation.isAdditive = true
        theAnimation.duration = duration
        theAnimation.fillMode = CAMediaTimingFillMode.both
        theAnimation.timingFunction = timing
        theAnimation.fromValue = 0
        theAnimation.toValue = 1
        layer.add(theAnimation, forKey: nil)
        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        (layer as! PCIconLayer).fraction = 1
//        CATransaction.commit()
        
    }
}

class PCIconGiarView: PCIconView{
    override func draw(_ layer: CALayer, in ctx: CGContext){
        dump(ctx)
        UIGraphicsPushContext(ctx)
        Icon.drawGiar(frame: bounds, resizing: .aspectFit, giarColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), giarStickColor: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), fraction: (layer as! PCIconLayer).fraction)
        UIGraphicsPopContext()
    }
}
