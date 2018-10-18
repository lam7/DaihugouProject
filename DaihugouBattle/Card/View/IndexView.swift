//
//  IndexView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/06/07.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension UIImage{
    static func indexImage(_ radius: CGFloat)-> UIImage?{
        let gradientColors: [UIColor] = [#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
        let gradientLocations: [CGFloat] = [0, 0.8, 1]
        UIGraphicsBeginImageContextWithOptions(CGSize(width: radius, height: radius), false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        
        let colors = gradientColors.map({$0.cgColor}) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()        
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
        ctx?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: radius, y: radius), options: [])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

//class CardIndexLayer: CATextLayer{
//    override var frame: CGRect{
//        didSet{
//            UIGraphicsBeginImageContext(frame.size)
//            draw(in: UIGraphicsGetCurrentContext()!)
//            contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
//            UIGraphicsEndImageContext()
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
//
//        font = UIFont.systemFont(ofSize: 10)
//        let size = UIFont.systemFont(ofSize: 10).withSize(frame.width * 0.8)
//        fontSize = size.pointSize
//    }
//
//    override func draw(in ctx: CGContext) {
//        let path = UIBezierPath(ovalIn: bounds)
//        path.addClip()
//
//        let gradientColors: [UIColor] = [#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
//        let gradientLocations: [CGFloat] = [0, 0.8, 1]
//        let colors = gradientColors.map({$0.cgColor}) as CFArray
//        let space = CGColorSpaceCreateDeviceRGB()
//        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
//        ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
//
//        super.draw(in: ctx)
//    }
//
//    func set(index: Int){
//        string = index.description
//        font?.sizeThatFits(<#T##size: CGSize##CGSize#>)
//        fontSize =  font?.sizeThatFits(bounds.size)
//    }
//}

class CardIndexView: UILabel{
    var gradientColors: [UIColor] = [#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
    var gradientLocations: [CGFloat] = [0, 0.8, 1]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp() {
        textAlignment = NSTextAlignment.center
        adjustsFontSizeToFitWidth = true
        numberOfLines = 1
        layer.masksToBounds = true
        textColor = .white
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: bounds)
        path.addClip()
        
        let ctx = UIGraphicsGetCurrentContext()
        let colors = gradientColors.map({$0.cgColor}) as CFArray
        
        let space = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
        
        ctx?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
        
        super.draw(rect)
    }
    
//    // TODO: 画像を毎回生成しているのを直す．(一回生成したらあとはコピー)
//    private func setUp(){
//        let imageView = UIImageView(frame: bounds)
//        imageView.contentMode = .scaleAspectFit
//        insertSubview(imageView, at: 0)
//        self.imageView = imageView
//        let radius = bounds.width / 2
//        DispatchQueue.global(qos: .userInteractive).async {
//            let image = UIImage.indexImage(radius)
//            DispatchQueue.main.async {
//                self.imageView.image = image
//            }
//        }
//    }
    
    func set(index: Int) {
        font = font.withSize(frame.height * 0.8)
        text = index.description
    }
}
//class IndexView: UILabel{
//    var gradientColors: [UIColor] = [#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
//    var gradientLocations: [CGFloat] = [0, 0.8, 1]
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setUpViews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setUpViews()
//    }
//
//    private func setUpViews() {
//        let gradient = CALayer()
//        gradient.contents = UIImage.indexImage(bounds.width)?.cgImage
//        layer.insertSublayer(gradient, at: 0)
//        textAlignment = NSTextAlignment.center
//        adjustsFontSizeToFitWidth = true
//        numberOfLines = 1
//        layer.masksToBounds = true
//        textColor = .white
//        backgroundColor = .clear
//    }
//
////    override init(frame: CGRect) {
////        super.init(frame: frame)
////        setUpViews()
////    }
////
////    required init?(coder aDecoder: NSCoder) {
////        super.init(coder: aDecoder)
////        setUpViews()
////    }
////
////    private func setUpViews() {
////        textAlignment = NSTextAlignment.center
////        adjustsFontSizeToFitWidth = true
////        numberOfLines = 1
////        layer.masksToBounds = true
////        textColor = .white
////        backgroundColor = .clear
////
////
////    }
////
////    override func draw(_ rect: CGRect) {
////        let r = frame.width / 2
////        layer.cornerRadius = r
////        let ctx = UIGraphicsGetCurrentContext()
////        let colors = gradientColors.map({$0.cgColor}) as CFArray
////
////        let space = CGColorSpaceCreateDeviceRGB()
////
////        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: gradientLocations)!
////
////        ctx?.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: frame.width, y: frame.height), options: [])
////
////        super.draw(rect)
////    }
////
//    func set(index: Int) {
//        font = font.withSize(frame.height * 0.8)
//        text = index.description
//    }
//
//}
