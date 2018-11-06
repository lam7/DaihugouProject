//
//  TutorialView.swift
//  DaihugouBattle
//
//  Created by main on 2018/11/06.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

class TutorialView: UIView{
    weak var maskLayer: CAShapeLayer!{
        didSet{
            maskLayer.fillRule = .evenOdd
            maskLayer.fillColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.9).cgColor
        }
    }
    
    weak var descriptionLabel: UILabel!{
        didSet{
            descriptionLabel.numberOfLines = 0
            descriptionLabel.backgroundColor = .clear
            descriptionLabel.textColor = .white
        }
    }
    
    var descriptionDirection: Direction = .down
    var descriptionSpace: CGFloat = 0
    private var descriptions: [String] = []
    private var targetsSpotFrame: [CGRect] = []
    private var targetsHitFrame: [CGRect] = []
    var spotType: SpotType = .circle
    
    enum Direction{
        case left, right, up, down
    }
    enum SpotType{
        case circle, square
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
        let maskLayer = CAShapeLayer()
        layer.addSublayer(maskLayer)
        self.maskLayer = maskLayer
        
        let descriptionLabel = UILabel()
        addSubview(descriptionLabel)
        self.descriptionLabel = descriptionLabel
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard self.bounds.contains(point) else{
            return false
        }
        guard let hitFrame = self.targetsHitFrame.first else{
            return true
        }
        return !hitFrame.contains(point)
    }

    private func fillRectLayer(){
        let path = UIBezierPath(rect: bounds)
        
        guard let spotFrame = targetsSpotFrame.first else{
            maskLayer.path = path.cgPath
            return
        }
        
        var cutPath: UIBezierPath
        switch spotType {
        case .circle:
            cutPath = UIBezierPath(ovalIn: spotFrame)
        case .square:
            cutPath = UIBezierPath(rect: spotFrame)
        }
        
        path.append(cutPath)
        
        maskLayer.path = path.cgPath
    }
    
    private func appearLabel(){
        guard let text = self.descriptions.first,
            let target = self.targetsSpotFrame.first else{
            return
        }
        
        descriptionLabel.text = text
        descriptionLabel.sizeToFit()

        let w = descriptionLabel.frame.width
        let h = descriptionLabel.frame.height
        switch descriptionDirection {
        case .up:
            var x = target.midX - w / 2
            x = max(0, x)
            x = min(UIScreen.main.bounds.width - w, x)
            descriptionLabel.frame = CGRect(x: x, y: target.minY - descriptionSpace - h, width: w, height: h)
        case .down:
            var x = target.midX - w / 2
            x = max(0, x)
            x = min(UIScreen.main.bounds.width - w, x)
            descriptionLabel.frame = CGRect(x: x, y: target.maxY + descriptionSpace, width: w, height: h)
        case .left:
            var y = target.midY - h / 2
            y = max(0, y)
            y = min(UIScreen.main.bounds.height - h, y)
            descriptionLabel.frame = CGRect(x: target.minX - descriptionSpace - w, y: y, width: w, height: h)
        case .right:
            var y = target.midY - h / 2
            y = max(0, y)
            y = min(UIScreen.main.bounds.height - h, y)
            descriptionLabel.frame = CGRect(x: target.maxX + descriptionSpace, y: y, width: w, height: h)
        }
    }
    
    
    func append(_ target: UIView, description: String){
        targetsSpotFrame.append(target.frame)
        targetsHitFrame.append(target.frame)
        descriptions.append(description)
    }
    
    func append(_ target: UIView, parent: UIViewController, description: String){
        let frame = parent.view.convert(target.frame, from: target)
        targetsSpotFrame.append(frame)
        targetsHitFrame.append(frame)
        descriptions.append(description)
    }
    
    func append(_ spot: CGRect, hit: CGRect, description: String){
        targetsSpotFrame.append(spot)
        targetsHitFrame.append(hit)
        descriptions.append(description)
    }
    
    func start(){
        fillRectLayer()
        appearLabel()
    }
    
    func next(){
        guard !targetsSpotFrame.isEmpty && !targetsHitFrame.isEmpty else{
            return
        }
        targetsSpotFrame.remove(at: 0)
        targetsHitFrame.remove(at: 0)
    }
}
