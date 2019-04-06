//
//  FrameView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/08.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

class CardBackFrameLayer: CALayer{
    var imageRect: CGRect{
        let w = frame.width * 0.85
        let h = w * 4 / 3
        return CGRect(x: (frame.width - w) / 2, y: frame.height - h, width: w, height: h)
    }
    
    override var frame: CGRect{
        didSet{
            UIGraphicsBeginImageContext(bounds.size)
            draw(in: UIGraphicsGetCurrentContext()!)
            contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
        }
    }
    
    enum ColorSetType: Int{
        case ur, sr, r, n
        private static let ColorSet: [[UIColor]] = [
            [#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)],
            [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)],
            [#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)],
            [#colorLiteral(red: 0.2, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.6, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.1176470588, green: 0, blue: 0, alpha: 1)],
            ]
        
        func colors()-> [UIColor]{
            return ColorSetType.ColorSet[self.rawValue]
        }
    }
    
    var colorSetType: ColorSetType = .n
    
    override func draw(in ctx: CGContext) {
        let gradientLocations: [CGFloat] = [0, 0.6, 1]
        let h = frame.height
        let topLeft = CGPoint(x: 0, y: imageRect.minY)
        let topRight = CGPoint(x: frame.width, y: imageRect.minY)
        let bottomLeft = CGPoint(x: 0, y: h)
        let bottomRight = CGPoint(x: frame.width, y: h)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y - imageRect.minX / 2))
        path.addLine(to: CGPoint(x: topRight.x, y: topRight.y - imageRect.minX / 2))
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        path.addClip()
        
        let colors = colorSetType.colors().map({$0.cgColor}) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
        ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
        
    }
}

class CardFrontFrameLayer: CALayer{
    var imageRect: CGRect{
        let w = frame.width * 0.85
        let h = w * 4 / 3
        return CGRect(x: (frame.width - w) / 2, y: frame.height - h, width: w, height: h)
    }
    
    override var frame: CGRect{
        didSet{
            UIGraphicsBeginImageContext(bounds.size)
            draw(in: UIGraphicsGetCurrentContext()!)
            contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
        }
    }
    
    enum ColorSetType: Int{
        case ur, sr, r, n
        private static let ColorSet: [[UIColor]] = [
            [#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)],
            [#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)],
            [#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)],
            [#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)],
        ]
        
        func colors()-> [UIColor]{
            return ColorSetType.ColorSet[self.rawValue]
        }
    }
    
    var colorSetType: ColorSetType = .n
    
    override func draw(in ctx: CGContext) {
        let w = frame.width
        let h = frame.height
        let cx = frame.midX
        
        let imageRect = self.imageRect
        
        let path = UIBezierPath()
        
        path.lineWidth = 5.0
        
        let tw = w / 3
        let th = h * 0.15
        let topCenter1 = CGPoint(x: cx - tw, y: -th / 8)
        let topCenter2 = CGPoint(x: cx + tw, y: -th / 8)
        let topLeft = CGPoint(x: imageRect.minX, y: imageRect.minY)
        let topRight = CGPoint(x: imageRect.maxX, y: imageRect.minY)
        path.move(to: topLeft)
        path.addCurve(to: topRight, controlPoint1: topCenter1, controlPoint2: topCenter2)
        path.close()

        let bottomLeft = CGPoint(x: imageRect.minX, y: h)
        let bottomRight = CGPoint(x: imageRect.maxX, y: h)
        path.move(to: topLeft)
        path.addLine(to: bottomLeft)
        path.close()
        
        path.move(to: topRight)
        path.addLine(to: bottomRight)
        path.close()
        
        let bh = h * 0.95
        let bw = w / 5
        let bottomCenter1 = CGPoint(x: cx - bw, y: bh)
        let botttomCenter2 = CGPoint(x: cx + bw, y: bh)
        path.move(to: bottomLeft)
        path.addCurve(to: bottomRight, controlPoint1: bottomCenter1, controlPoint2: botttomCenter2)
        path.close()
        
        let cw = imageRect.width / 8
        let ch = imageRect.height / 10
        let curveLeftB = CGPoint(x: imageRect.minX + cw, y: imageRect.minY)
        let curveLeftC1 = CGPoint(x: imageRect.minX + cw * 0.8, y: imageRect.minY + ch * 0.9)
        let curveLeftC2 = CGPoint(x: imageRect.minX + cw * 0.2 , y: imageRect.minY + ch * 0.8)
        let curveLeftE = CGPoint(x: imageRect.minX, y: imageRect.minY + ch)
        path.move(to: curveLeftB)
        path.addCurve(to: curveLeftE, controlPoint1: curveLeftC1, controlPoint2: curveLeftC2)
        path.addLine(to: topLeft)
        path.close()
        
        let curveRightB = CGPoint(x: imageRect.maxX - cw, y: imageRect.minY)
        let curveRightC1 = CGPoint(x: imageRect.maxX - cw * 0.8, y: imageRect.minY + ch * 0.9)
        let curveRightC2 = CGPoint(x: imageRect.maxX - cw * 0.2 , y: imageRect.minY + ch * 0.8)
        let curveRightE = CGPoint(x: imageRect.maxX, y: imageRect.minY + ch)
        path.move(to: curveRightB)
        path.addCurve(to: curveRightE, controlPoint1: curveRightC1, controlPoint2: curveRightC2)
        path.addLine(to: topRight)
        path.close()
   
        path.addClip()
        
        let gradientLocations: [CGFloat] = [0, 0.3, 1]
        
        let colors = colorSetType.colors().map({$0.cgColor}) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
        ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
    }
    
}
class CardFrame: UIView{
    var frameLayers: [String : CAGradientLayer] = [:]
    var imageRect: CGRect{
        let w = frame.width * 0.85
        let h = w * 4 / 3
        return CGRect(x: (frame.width - w) / 2, y: frame.height - h, width: w, height: h)
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
        let imageRect = self.imageRect
        frameLayers["top"] =  CAGradientLayer()
        frameLayers["left"] = CAGradientLayer()
        frameLayers["right"] = CAGradientLayer()
        frameLayers["bottom"] = CAGradientLayer()
        frameLayers["curveLeft"] = CAGradientLayer()
        frameLayers["curveRight"] = CAGradientLayer()
        
        frameLayers["top"]?.startPoint = CGPoint(x: 0, y: 0.5)
        frameLayers["top"]?.endPoint = CGPoint(x: 1, y: 0.5)
        frameLayers["bottom"]?.startPoint = CGPoint(x: 0, y: 0.5)
        frameLayers["bottom"]?.endPoint = CGPoint(x: 1, y: 0.5)
        frameLayers["curveLeft"]?.startPoint = CGPoint(x: 1, y: 0)
        frameLayers["curveLeft"]?.endPoint = CGPoint(x: 0, y: 1)
        frameLayers["curveRight"]?.startPoint = CGPoint(x: 0, y: 0)
        frameLayers["curveRight"]?.endPoint = CGPoint(x: 1, y: 1)
        
        frameLayers.forEach({
            $0.value.frame = bounds
            
            $0.value.colors = [
                #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1).cgColor,
                #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).cgColor,
                #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1).cgColor
            ]
            $0.value.locations = [0, 0.3, 1]
        })
        
        frameLayers.forEach({
            layer.addSublayer($0.value)
        })
    }
    override func draw(_ rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        
        let imageRect = self.imageRect
        
        var path = UIBezierPath()
        var shapeLayer = CAShapeLayer()
        
        let tw = w / 3
        let th = h * 0.15
        let topCenter1 = CGPoint(x: cx - tw, y: -th / 8)
        let topCenter2 = CGPoint(x: cx + tw, y: -th / 8)
        let topLeft = CGPoint(x: imageRect.minX, y: imageRect.minY)
        let topRight = CGPoint(x: imageRect.maxX, y: imageRect.minY)
        path.move(to: topLeft)
        path.addCurve(to: topRight, controlPoint1: topCenter1, controlPoint2: topCenter2)
        path.close()
        shapeLayer.lineWidth = imageRect.minX / 3
        shapeLayer.path = path.cgPath
        frameLayers["top"]?.mask = shapeLayer
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        
        
        let bottomLeft = CGPoint(x: imageRect.minX, y: h)
        let bottomRight = CGPoint(x: imageRect.maxX, y: h)
        path.move(to: topLeft)
        path.addLine(to: bottomLeft)
        shapeLayer.path = path.cgPath
        frameLayers["left"]?.mask = shapeLayer
        shapeLayer.lineWidth = imageRect.minX / 2.2
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        path.move(to: topRight)
        path.addLine(to: bottomRight)
        shapeLayer.path = path.cgPath
        frameLayers["right"]?.mask = shapeLayer
        path = UIBezierPath()
        shapeLayer.lineWidth = imageRect.minX / 2.2
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        let bh = h * 0.95
        let bw = w / 5
        let bottomCenter1 = CGPoint(x: cx - bw, y: bh)
        let botttomCenter2 = CGPoint(x: cx + bw, y: bh)
        path.move(to: bottomLeft)
        path.addCurve(to: bottomRight, controlPoint1: bottomCenter1, controlPoint2: botttomCenter2)
        path.close()
        shapeLayer.path = path.cgPath
        frameLayers["bottom"]?.mask = shapeLayer
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        let cw = imageRect.width / 8
        let ch = imageRect.height / 10
        let curveLeftB = CGPoint(x: imageRect.minX + cw, y: imageRect.minY)
        let curveLeftC1 = CGPoint(x: imageRect.minX + cw * 0.8, y: imageRect.minY + ch * 0.9)
        let curveLeftC2 = CGPoint(x: imageRect.minX + cw * 0.2 , y: imageRect.minY + ch * 0.8)
        let curveLeftE = CGPoint(x: imageRect.minX, y: imageRect.minY + ch)
        path.move(to: curveLeftB)
        path.addCurve(to: curveLeftE, controlPoint1: curveLeftC1, controlPoint2: curveLeftC2)
        path.addLine(to: topLeft)
        path.close()
        shapeLayer.path = path.cgPath
        
        frameLayers["curveLeft"]?.mask = shapeLayer
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        let curveRightB = CGPoint(x: imageRect.maxX - cw, y: imageRect.minY)
        let curveRightC1 = CGPoint(x: imageRect.maxX - cw * 0.8, y: imageRect.minY + ch * 0.9)
        let curveRightC2 = CGPoint(x: imageRect.maxX - cw * 0.2 , y: imageRect.minY + ch * 0.8)
        let curveRightE = CGPoint(x: imageRect.maxX, y: imageRect.minY + ch)
        path.move(to: curveRightB)
        path.addCurve(to: curveRightE, controlPoint1: curveRightC1, controlPoint2: curveRightC2)
        path.addLine(to: topRight)
        path.close()
        shapeLayer.path = path.cgPath
        frameLayers["curveRight"]?.mask = shapeLayer
        path = UIBezierPath()
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
    }
}


/*
 class CardBackFrame: UIView{
 var imageRect: CGRect{
 let w = frame.width * 0.85
 let h = w * 4 / 3
 return CGRect(x: (frame.width - w) / 2, y: frame.height - h, width: w, height: h)
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
 backLayer = CAGradientLayer()
 backLayer.frame = bounds
 
 backLayer.colors = [
 #colorLiteral(red: 0.2, green: 0, blue: 0, alpha: 1).cgColor,
 #colorLiteral(red: 0.6, green: 0, blue: 0, alpha: 1).cgColor,
 #colorLiteral(red: 0.1176470588, green: 0, blue: 0, alpha: 1).cgColor
 ]
 backLayer.locations = [0, 0.6, 1]
 layer.addSublayer(backLayer)
 }
 
 override func draw(_ rect: CGRect) {
 if rect == .zero{ return }
 let path = UIBezierPath()
 let shapeLayer = CAShapeLayer()
 let h = rect.height
 let topLeft = CGPoint(x: 0, y: imageRect.minY)
 let topRight = CGPoint(x: rect.width, y: imageRect.minY)
 let bottomLeft = CGPoint(x: 0, y: h)
 let bottomRight = CGPoint(x: rect.width, y: h)
 
 path.move(to: CGPoint(x: topLeft.x, y: topLeft.y - imageRect.minX / 2))
 path.addLine(to: CGPoint(x: topRight.x, y: topRight.y - imageRect.minX / 2))
 path.addLine(to: bottomRight)
 path.addLine(to: bottomLeft)
 path.close()
 shapeLayer.lineWidth = imageRect.minX * 2
 shapeLayer.path = path.cgPath
 backLayer.mask = shapeLayer
 }
 }
 class CardFrame: UIView{
 var frameLayers: [String : CAGradientLayer] = [:]
 var imageRect: CGRect{
 let w = frame.width * 0.85
 let h = w * 4 / 3
 return CGRect(x: (frame.width - w) / 2, y: frame.height - h, width: w, height: h)
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
 let imageRect = self.imageRect
 frameLayers["top"] =  CAGradientLayer()
 frameLayers["left"] = CAGradientLayer()
 frameLayers["right"] = CAGradientLayer()
 frameLayers["bottom"] = CAGradientLayer()
 frameLayers["curveLeft"] = CAGradientLayer()
 frameLayers["curveRight"] = CAGradientLayer()
 
 frameLayers["top"]?.startPoint = CGPoint(x: 0, y: 0.5)
 frameLayers["top"]?.endPoint = CGPoint(x: 1, y: 0.5)
 frameLayers["bottom"]?.startPoint = CGPoint(x: 0, y: 0.5)
 frameLayers["bottom"]?.endPoint = CGPoint(x: 1, y: 0.5)
 frameLayers["curveLeft"]?.startPoint = CGPoint(x: 1, y: 0)
 frameLayers["curveLeft"]?.endPoint = CGPoint(x: 0, y: 1)
 frameLayers["curveRight"]?.startPoint = CGPoint(x: 0, y: 0)
 frameLayers["curveRight"]?.endPoint = CGPoint(x: 1, y: 1)
 
 frameLayers.forEach({
 $0.value.frame = bounds
 
 $0.value.colors = [
 #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1).cgColor,
 #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).cgColor,
 #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1).cgColor
 ]
 $0.value.locations = [0, 0.3, 1]
 
 $0.value
 })
 
 frameLayers.forEach({
 layer.addSublayer($0.value)
 })
 }
 override func draw(_ rect: CGRect) {
 let w = rect.width
 let h = rect.height
 let cx = rect.midX
 let cy = rect.midY
 let imageRect = self.imageRect
 
 var path = UIBezierPath()
 var shapeLayer = CAShapeLayer()
 
 let tw = w / 3
 let th = h * 0.15
 let topCenter1 = CGPoint(x: cx - tw, y: -th / 8)
 let topCenter2 = CGPoint(x: cx + tw, y: -th / 8)
 let topLeft = CGPoint(x: imageRect.minX, y: imageRect.minY)
 let topRight = CGPoint(x: imageRect.maxX, y: imageRect.minY)
 path.move(to: topLeft)
 path.addCurve(to: topRight, controlPoint1: topCenter1, controlPoint2: topCenter2)
 path.close()
 shapeLayer.lineWidth = imageRect.minX / 3
 shapeLayer.path = path.cgPath
 frameLayers["top"]?.mask = shapeLayer
 path = UIBezierPath()
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 
 
 
 let bottomLeft = CGPoint(x: imageRect.minX, y: h)
 let bottomRight = CGPoint(x: imageRect.maxX, y: h)
 path.move(to: topLeft)
 path.addLine(to: bottomLeft)
 shapeLayer.path = path.cgPath
 frameLayers["left"]?.mask = shapeLayer
 shapeLayer.lineWidth = imageRect.minX / 2.2
 path = UIBezierPath()
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 
 path.move(to: topRight)
 path.addLine(to: bottomRight)
 shapeLayer.path = path.cgPath
 frameLayers["right"]?.mask = shapeLayer
 path = UIBezierPath()
 shapeLayer.lineWidth = imageRect.minX / 2.2
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 
 let bh = h * 0.95
 let bw = w / 5
 let bottomCenter1 = CGPoint(x: cx - bw, y: bh)
 let botttomCenter2 = CGPoint(x: cx + bw, y: bh)
 path.move(to: bottomLeft)
 path.addCurve(to: bottomRight, controlPoint1: bottomCenter1, controlPoint2: botttomCenter2)
 path.close()
 shapeLayer.path = path.cgPath
 frameLayers["bottom"]?.mask = shapeLayer
 path = UIBezierPath()
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 
 let cw = imageRect.width / 8
 let ch = imageRect.height / 10
 let curveLeftB = CGPoint(x: imageRect.minX + cw, y: imageRect.minY)
 let curveLeftC1 = CGPoint(x: imageRect.minX + cw * 0.8, y: imageRect.minY + ch * 0.9)
 let curveLeftC2 = CGPoint(x: imageRect.minX + cw * 0.2 , y: imageRect.minY + ch * 0.8)
 let curveLeftE = CGPoint(x: imageRect.minX, y: imageRect.minY + ch)
 path.move(to: curveLeftB)
 path.addCurve(to: curveLeftE, controlPoint1: curveLeftC1, controlPoint2: curveLeftC2)
 path.addLine(to: topLeft)
 path.close()
 shapeLayer.path = path.cgPath
 
 frameLayers["curveLeft"]?.mask = shapeLayer
 path = UIBezierPath()
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 
 let curveRightB = CGPoint(x: imageRect.maxX - cw, y: imageRect.minY)
 let curveRightC1 = CGPoint(x: imageRect.maxX - cw * 0.8, y: imageRect.minY + ch * 0.9)
 let curveRightC2 = CGPoint(x: imageRect.maxX - cw * 0.2 , y: imageRect.minY + ch * 0.8)
 let curveRightE = CGPoint(x: imageRect.maxX, y: imageRect.minY + ch)
 path.move(to: curveRightB)
 path.addCurve(to: curveRightE, controlPoint1: curveRightC1, controlPoint2: curveRightC2)
 path.addLine(to: topRight)
 path.close()
 shapeLayer.path = path.cgPath
 frameLayers["curveRight"]?.mask = shapeLayer
 path = UIBezierPath()
 shapeLayer = CAShapeLayer()
 shapeLayer.strokeColor = UIColor.white.cgColor
 }
 }

 */
