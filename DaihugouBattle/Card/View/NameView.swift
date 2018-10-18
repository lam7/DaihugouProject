//
//  NameView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/13.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

//class CardNameLayer: CATextLayer{
//    override var frame: CGRect{
//        didSet{
//            UIGraphicsBeginImageContext(frame.size)
//            draw(in: UIGraphicsGetCurrentContext()!)
//            contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
//            UIGraphicsEndImageContext()
//        }
//    }
//
//    override var string: Any?{
//        didSet{
//            if let text = string as? String{
//                var h = frame.height * 2 / 3
//                if h * CGFloat(text.count) > frame.width * 0.78{
//                    h = frame.width * 0.78 / CGFloat(text.count)
//                }
//                font = UIFont.boldSystemFont(ofSize: 20).withSize(h)
//            }
//        }
//    }
//
//    override init(){
//        super.init()
//        setUp()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUp()
//    }
//
//    private func setUp(){
//        foregroundColor = UIColor.white.cgColor
//        contentsScale = UIScreen.main.scale
//        alignmentMode = kCAAlignmentCenter
//    }
//
//    override func draw(in ctx: CGContext) {
//        let topLeft = CGPoint(x: frame.width / 10, y: 0)
//        let bottomLeft = CGPoint(x: frame.width / 10, y: frame.height)
//        let centerLeft = CGPoint(x: 0, y: frame.height / 2)
//
//        let topRight = CGPoint(x: frame.width * 0.9, y: 0)
//        let bottomRight = CGPoint(x: frame.width * 0.9, y: frame.height)
//        let centerRight = CGPoint(x: frame.width, y: frame.height / 2)
//
//        let path = UIBezierPath()
//        path.move(to: topLeft)
//        path.addLine(to: topRight)
//        path.addQuadCurve(to: bottomRight, controlPoint: centerRight)
//        path.addLine(to: bottomLeft)
//        path.addQuadCurve(to: topLeft, controlPoint: centerRight)
//        path.close()
//
//        path.addClip()
//
//        let gradientColors: [UIColor] = [#colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)]
//        let gradientLocations: [CGFloat] = [0, 0.6, 1]
//        let colors = gradientColors.map({$0.cgColor}) as CFArray
//        let space = CGColorSpaceCreateDeviceRGB()
//        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
//        ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
//
//        super.draw(in: ctx)
//    }
////    override func draw(in ctx: CGContext) {
////        let gradientColors: [UIColor] = [#colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)]
////        let gradientLocations: [CGFloat] = [0, 0.6, 1]
////        let colors = gradientColors.map({$0.cgColor}) as CFArray
////        let space = CGColorSpaceCreateDeviceRGB()
////        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
////        ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
////        let leftMargin = frame.width / 6
////        let rect = CGRect(x: leftMargin, y: 0, width: frame.width - leftMargin, height: frame.height)
////        chName.draw(in: rect, withAttributes: nil)
////    }
//}

class CardNameView: UILabel{
    var gradientColors: [UIColor] = [#colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1),#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1),#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)]
    var gradientLocations: [CGFloat] = [0, 0.6, 1]
    var cornerRadius: CGFloat = 5
    
    override var text: String?{
        didSet{
            guard let text = text else{ return }
            var h = frame.height * 2 / 3
            if h * CGFloat(text.count) > frame.width * 0.78{
                h = frame.width * 0.78 / CGFloat(text.count)
            }
            self.font = self.font.withSize(h)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    private func setUpViews() {
        backgroundColor = .clear
        textAlignment = NSTextAlignment.center
        adjustsFontSizeToFitWidth = true
        numberOfLines = 1
        layer.masksToBounds = true
        textColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        
        let ctx = UIGraphicsGetCurrentContext()
        let colors = gradientColors.map({$0.cgColor}) as CFArray
        
        let space = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
        
        ctx?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
        
        super.draw(rect)
    }
}
