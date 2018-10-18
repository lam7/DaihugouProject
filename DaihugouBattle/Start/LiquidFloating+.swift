//
//  LiquidFloatingLabelCell.swift
//  DaihugouBattle
//
//  Created by main on 2018/08/21.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import LiquidFloatingActionButton

public class LiquidFloatingLabelCell : LiquidFloatingCell{
    var name: String = ""
    
    init(icon: UIImage, name: String) {
        self.name = name
        super.init(icon: icon)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setupView(_ view: UIView) {
        super.setupView(view)
        let label = UILabel()
        label.text = name
        label.textColor = UIColor.white
        label.font = UIFont(name: "Helvetica-Neue", size: 12)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.right.equalTo(snp.left).offset(-5)
            make.top.height.equalTo(self)
        }
    }
}


public class LiquidFloatignActionPlusButton: LiquidFloatingActionButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        rotationDegrees = 90.0
    }
    override public func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = convertToCAShapeLayerLineCap(convertFromCAShapeLayerLineCap(CAShapeLayerLineCap.round))
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let w = frame.width
        let h = frame.height
        
        let points = [
            (CGPoint(x: w * 0.25, y: h * 0.35), CGPoint(x: w * 0.75, y: h * 0.35)),
            (CGPoint(x: w * 0.25, y: h * 0.5), CGPoint(x: w * 0.75, y: h * 0.5)),
            (CGPoint(x: w * 0.25, y: h * 0.65), CGPoint(x: w * 0.75, y: h * 0.65))
        ]
        
        let path = UIBezierPath()
        for (start, end) in points {
            path.move(to: start)
            path.addLine(to: end)
        }
        
        plusLayer.path = path.cgPath
        
        return plusLayer
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
    return CAShapeLayerLineCap(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineCap(_ input: CAShapeLayerLineCap) -> String {
    return input.rawValue
}
