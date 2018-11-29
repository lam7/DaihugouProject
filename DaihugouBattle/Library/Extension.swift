//
//  Extension.swift
//
//  Created by Hiroki Oka on 2017/08/21.
//  Copyright © 2017年 Hiroki Oka. All rights reserved.
//
//  このファイルを作業中のプロジェクトに入れると開発が楽になる
//
// *,/　Int (* or /) (CGFloat or Double or Float)の対応。結果は(CGFloat, Double, Float)になる
// *=, /= (CGFloat, Double, Float) (*=,/=) Intの対応。逆は対応していない
// +, += Dictionaty　二つのDictionaryを結合させる
// +,+=,-,-= 2つのCGPointをそれぞれの演算子で計算
// *,/ CGPoint*CGFloatの対応。それぞれの方向をCGFloat倍する
// *=,/= CGPoint (*=,/=) Int の対応
//
//　Operator
//  >=? ３項演算子 ２つの内大きい方を返す
//  <=? ３項演算子 ２つの内小さい方を返す
//　+-　 演算子　左辺　(+ or -) 右辺　を返す (+-はランダム)
//　**　演算子　左辺の右辺乗を返す
//
//　Extension Int, Double, Float, CGFloat
//  .d　Doubleへキャスト
//  .f　Floatへキャスト
//  .i　Intへキャスト
//  .cf CGFloatへキャスト
//　.random 0〜自身の数の範囲でランダムな数を返す
//　.randomSign　ランダムで自身の数字をプラスかマイナスに決める
//  - Float.d　がDouble型にキャスト出来ていなかったのを修正 (2018/1/18)
//
// Extension CGRect
// init(origin: CGPoint, width: CGFloat, height: CGFloat)の追加
// init(x: CGFloat, y: CGFloat, size: CGSize)の追加
//
//　Extension Array
//　.inRange　引数の数字が配列の要素数の範囲にいるかどうかチェックする
//　.outOfRange 引数の数字が配列の外にいるかどうかチェックする
//  .combineSort 複数の条件でsortする
//　subscript[safe] 安全に配列から要素を取り出す。範囲外に数字があるならnilを返す
//  Element: Equatable
//　.removeAll 引数の要素と一致する要素を自身の配列からすべて消す
//
//　Extension String
//　.i,.d,.f それぞれにキャスト(不可能ならnil)
//　.startWith　引数の文字で始まるかどうかチェックする
//
//　Extension UIView
//  .screenShot　自身のビューのスクリーンショットを撮る
//  .parentViewController 自身が属しているViewControllerを返す
//  .removeAllSubviews 自身にviewに乗っている全てのviewを取り除く
//
//  Extension UIImage
//  .divImage 画像を引数で分割して[UIImage]を返す
//  .compose 引数の画像を全て合成する
//  .image 指定サイズで単色で塗りつぶされた画像を生成
//  .image 指定サイズでグラディエーションされた画像を生成
//
//  Extension Dictionary
//  .union 二つのDictionaryを結合させる
//
// protocol EnumEnumerable
//　要素を配列にする・enumeratorを作成
//  例) enum Test: EnumEnumerable{ case a, b, c }
//      func forLoop(){
//          //enumの全ての要素をfor文で回せる
//          //for t in Test.cases{}    or
//            for t in Test.enumarate(){}
//       }
//
//　Function
//　probability(_: Double) 引数の確率で起こる事象で真か儀を返す 引数: 0 ~ 1の実数
//　probability(nume: UInt32, deno: UInt32) nume / deno％で起きる事象で真か儀を返す

import Foundation
import SpriteKit

public func * (lhs: Int, rhs: CGFloat)-> CGFloat{
    return CGFloat(lhs) * rhs
}

public func * (lhs: CGFloat, rhs: Int)-> CGFloat{
    return lhs * CGFloat(rhs)
}

public func *= (lhs: inout CGFloat, rhs: Int){
    lhs = lhs * rhs
}

public func * (lhs: Double, rhs: Int)-> Double{
    return lhs * Double(rhs)
}

public func * (lhs: Int, rhs: Double)-> Double{
    return Double(lhs) * rhs
}

public func *= (lhs: inout Double, rhs: Int){
    lhs = lhs * rhs
}

public func * (lhs: Float, rhs: Int)-> Float{
    return lhs * Float(rhs)
}

public func * (lhs: Int, rhs: Float)-> Float{
    return Float(lhs) * rhs
}

public func *= (lhs: inout Float, rhs: Int){
    lhs = lhs * rhs
}

public func / (lhs: Int, rhs: CGFloat)-> CGFloat{
    return CGFloat(lhs) / rhs
}

public func / (lhs: CGFloat, rhs: Int)-> CGFloat{
    return lhs / CGFloat(rhs)
}

public func /= (lhs: inout CGFloat, rhs: Int){
    lhs = lhs / rhs
}

public func / (lhs: Double, rhs: Int)-> Double{
    return lhs / Double(rhs)
}

public func / (lhs: Int, rhs: Double)-> Double{
    return Double(lhs) / rhs
}

public func /= (lhs: inout Double, rhs: Int){
    lhs = lhs / rhs
}

public func / (lhs: Float, rhs: Int)-> Float{
    return lhs / Float(rhs)
}

public func / (lhs: Int, rhs: Float)-> Float{
    return Float(lhs) / rhs
}

public func /= (lhs: inout Float, rhs: Int){
    lhs = lhs / rhs
}

public func +<K, V>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) -> Dictionary<K, V> {
    return lhs.union(rhs)
}

public func +=<K, V>(lhs: inout Dictionary<K, V>, rhs: Dictionary<K, V>) {
    lhs = lhs + rhs
}

public func +<T: Any>(lhs: [T], rhs: T)-> [T]{
    var copy = lhs
    copy.append(rhs)
    return copy
}

public func +=<T: Any>(lhs: inout [T], rhs: T){
    lhs.append(rhs)
}



public func +(lhs: CGPoint, rhs: CGPoint)-> CGPoint{
    return CGPoint(x: lhs.x + rhs.x, y: lhs.x + rhs.y)
}

public func -(lhs: CGPoint, rhs: CGPoint)-> CGPoint{
    return CGPoint(x: lhs.x - rhs.x, y: lhs.x - rhs.y)
}

public func +=(lhs: inout CGPoint, rhs: CGPoint){
    lhs = lhs + rhs
}

public func -=(lhs: inout CGPoint, rhs: CGPoint){
    lhs = lhs - rhs
}

public func *(lhs: CGPoint, rhs: CGFloat)-> CGPoint{
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

public func *(lhs: CGFloat, rhs: CGPoint)-> CGPoint{
    return CGPoint(x: rhs.x * lhs, y: rhs.y * lhs)
}

public func *=(lhs: inout CGPoint, rhs: CGFloat){
    lhs = lhs * rhs
}

public func /(lhs: CGPoint, rhs: CGFloat)-> CGPoint{
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

public func /(lhs: CGFloat, rhs: CGPoint)-> CGPoint{
    return CGPoint(x: rhs.x / lhs, y: rhs.y / lhs)
}

public func /=(lhs: inout CGPoint, rhs: CGFloat){
    lhs = lhs / rhs
}



public func *(lhs: CGSize, rhs: CGFloat)-> CGSize{
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

public func *=(lhs: inout CGSize, rhs: CGFloat){
    lhs = lhs * rhs
}

public func /(lhs: CGSize, rhs: CGFloat)-> CGSize{
    return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
}

public func /=(lhs: inout CGSize, rhs: CGFloat){
    lhs = lhs / rhs
}

//public func print(file: String = #file, function: String = #function, line: Int = #line, _ message: String = "") {
//    print("\(file).\(function) #\(line): \(message)" as Any)
//}


infix operator ** : MultiplicationPrecedence

extension Int{
    /// Cast to Double
    public var d: Double{ return Double(self) }
    
    /// Cast to Float
    public var f: Float{ return Float(self) }
    
    /// Cast to CGFloat
    public var cf: CGFloat{ return CGFloat(self) }
    
    /// Cast to NSNubmer
    public var nsNumber: NSNumber{ return NSNumber(value: self) }
    
    /// Calculate an exponentiation
    ///
    /// - Parameters:
    ///   - lhs: radix
    ///   - rhs: exponent
    /// - Returns: lhs ^ rhs
    public static func **(lhs: Int, rhs: Int)-> Int{
        var r: Int = 1
        if rhs == 0{
            return 1
        }
        
        for _ in 0..<abs(rhs){
            r *= lhs
        }
        return rhs < 0 ? 1 / rhs : rhs
    }
}

extension Float{
    /// Cast to Int
    public var i: Int{ return Int(self) }
    
    /// Cast to Double
    public var d: Double{ return Double(self) }
    
    /// Cast to CGFloat
    public var cf: CGFloat{ return CGFloat(self) }
    
    /// Cast to NSNubmer
    public var nsNumber: NSNumber{ return NSNumber(value: self) }
    
    /// The mathematical constant 2pi
    public var pi2: Float{ return Float.pi * 2.0}
    
    
    /// Calculate an exponentiation
    ///
    /// - Parameters:
    ///   - lhs: radix
    ///   - rhs: exponent
    /// - Returns: lhs ^ rhs
    public static func **(lhs: Float, rhs: Int)-> Float{
        var r: Float = 1
        if rhs == 0{
            return 1
        }
        for _ in 0..<abs(rhs){
            r *= lhs
        }
        return rhs < 0 ? 1 / r : r
    }
}

extension Double{
    /// Cast to Int
    public var i: Int{return Int(self)}
    
    /// Cast to Float
    public var f: Float{return Float(self)}
    
    /// Cast to CGFloat
    public var cf: CGFloat{return CGFloat(self)}
    
    /// Cast to NSNubmer
    public var nsNumber: NSNumber{ return NSNumber(value: self) }
    
    /// The mathematical constant 2pi
    public var pi2: Double{ return Double.pi * 2.0}
    
    /// Calculate an exponentiation
    ///
    /// - Parameters:
    ///   - lhs: radix
    ///   - rhs: exponent
    /// - Returns: lhs ^ rhs
    public static func **(lhs: Double, rhs: Int)-> Double{
        var r: Double = 1
        if rhs == 0{
            return 1
        }
        for _ in 0..<abs(rhs){
            r *= lhs
        }
        return rhs < 0 ? 1 / r : r
    }
}


extension CGFloat{
    /// Cast to Int
    public var i: Int{return Int(self)}
    
    /// Cast to Float
    public var f: Float{return Float(self)}
    
    /// Cast to Double
    public var d: Double{return Double(self)}
    
    /// The mathematical constant 2pi
    public var pi2: CGFloat{ return CGFloat.pi * 2.0}
 
    /// Calculate an exponentiation
    ///
    /// - Parameters:
    ///   - lhs: radix
    ///   - rhs: exponent
    /// - Returns: lhs ^ rhs
    public static func **(lhs: CGFloat, rhs: Int)-> CGFloat{
        var r: CGFloat = 1
        if rhs == 0{
            return 1
        }
        for _ in 0..<abs(rhs){
            r *= lhs
        }
        return rhs < 0 ? 1 / r : r
    }
}

extension CGRect{
    init(origin: CGPoint, width: CGFloat, height: CGFloat){
        self.init(x: origin.x, y: origin.y, width: width, height: height)
    }
    
    init(x: CGFloat, y: CGFloat, size: CGSize){
        self.init(x: x, y: y, width: size.width, height: size.height)
    }
    
    init(center frame: CGRect, width: CGFloat, height: CGFloat){
        self.init(x: frame.midX - width / 2, y: frame.midY - height / 2, width: width, height: height)
    }
}

extension Array{
    /// Check argument is within self.count
    ///
    /// - Parameter n: search count value in this array
    /// - Returns: return true if n is within self.count
    public func inRange(_ n: Int)-> Bool{
        if self.count <= n || n < 0 || self.isEmpty{
            return false
        }else{
            return true
        }
    }

    /// Check argument out of Range self.count
    ///
    /// - Parameter n: search count value in this array
    /// - Returns: return true if n out of Range self.count
    public func outOfRange(_ n: Int)-> Bool{
        if self.count <= n || n < 0 || self.isEmpty{
            return true
        }else{
            return false
        }
    }
    
    
    /// 安全に要素を取り出す
    ///
    /// - Parameter index: インデックス
    /// - Returns:　指定のインデックスに要素があるならそれを，ないならnilを返す
    subscript(safe index: Int)-> Element?{
        if inRange(index){
            return self[index]
        }else{
            return nil
        }
    }
    
    /// 安全に要素を削除し取り出す
    ///
    /// - Parameter at: インデックス
    /// - Returns:　指定のインデックスに要素があるならそれを削除し返す，ないならnilを返す
    @discardableResult
    public mutating func remove(safe at: Int)-> Element?{
        if inRange(at){
            return remove(at: at)
        }else{
            return nil
        }
    }
    
    mutating func sort(bys areInIncreasingOrder: [(Element, Element) -> Bool]){
        
        typealias SortDescriptor = (Element, Element) -> Bool
        func combine(sortDescriptors: [SortDescriptor]) -> SortDescriptor{
            return { lhs, rhs in
                for isOrderedBefore in sortDescriptors {
                    if isOrderedBefore(lhs,rhs) { return true }
                    if isOrderedBefore(rhs,lhs) { return false }
                }
                return false
            }
        }
        
        sort(by: combine(sortDescriptors: areInIncreasingOrder))
    }
}

extension Array where Element: Equatable{
    /// 引数と一緒の要素を自身の配列からすべて消す
    ///
    /// - Parameter element: 消す要素
    public mutating func removeAll(_ element: Element){
        for i in (0..<count).reversed(){
            if self[i] == element{
                self.remove(at: i)
            }
        }
    }
    
    @discardableResult
    public mutating func removeFirst(safe element: Element)-> Element?{
        guard let i = index(of: element) else{
            return nil
        }
        return remove(at: i)
    }
    
    public mutating func removeDuplicates(){
        let orderedSet = NSOrderedSet(array: self)
        self = orderedSet.array as! Array<Element>
    }
    
    func collection()-> [(Element, Int)]{
        var copy = self
        var counts: [(Element, Int)] = []
        while !copy.isEmpty{
            let e = copy.filter{ $0 == copy.first! }
            copy = copy.filter({ $0 != e.first! })
            counts.append((e.first!, e.count))
        }
        return counts
    }
}

extension String {
    public var i: Int?{ return Int(self) }
    public var d: Double?{ return Double(self) }
    public var f: Float?{ return Float(self) }
    
    
    /// Check if it starts with argument
    ///
    /// - Parameter string: search text
    /// - Returns: return true if start with argument
   public func startsWith(_ string: String) -> Bool {
        guard let range = range(of: string, options:[.caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
}


extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}


extension UIView{
    /// viewのスクリーンショット
    /// - return: その瞬間のview画像
    public func screenShot()-> UIImage{
        let UIView = self
        UIGraphicsBeginImageContextWithOptions(UIView.frame.size, false, 1.0)
        UIView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// - Returns:　自身が属しているUIViewController
    public func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }
    
    /// 自身にviewに乗っている全てのviewを取り除く
    public func removeAllSubviews(){
        subviews.forEach{
            $0.removeFromSuperview()
        }
    }
    
    /// 自身がスーパービューに属しているならスーパービューから取り除く
    public func removeSafelyFromSuperview(){
        if superview != nil{
            removeFromSuperview()
        }
    }
    
    public static func loadNib(_ parent: UIView, withOwner owner: Any? = nil)-> UIView?{
        guard let view = Bundle(for: type(of: self) as! AnyClass).loadNibNamed(parent.className, owner: self, options: nil)?.first as? UIView else{
            return nil
        }
        view.frame = parent.frame
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        parent.addSubview(view)
        return view
    }
}

extension UIImage{
    
    /// 画像分割読み込み
    ///
    /// - Parameters:
    ///   - named: 画像名
    ///   - xNum: x方向に何分割するか　画像の横幅は画像の横幅÷xNumで決まる
    ///   - yNum: y方向に何分割するか　画像の縦幅は画像の縦幅÷yNumで決まる
    /// - Returns: xNum * yNum個の分割されたUIImage
    public static func divImage(_ named: String, xNum: Int, yNum: Int)-> [UIImage]?{
        guard let image = UIImage(named: named) else{
            return nil
        }
        let width = image.size.width / CGFloat(xNum)
        let height = image.size.height / CGFloat(yNum)
        var imgs: [UIImage] = []
        for y in 0..<yNum{
            for x in 0..<xNum{
                imgs.append(clipImage(image, x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height))
            }
        }
        return imgs
    }
    
    /// 画像分割読み込み
    ///
    /// - Parameters:
    ///   - xNum: x方向に何分割するか　画像の横幅は画像の横幅÷xNumで決まる
    ///   - yNum: y方向に何分割するか　画像の縦幅は画像の縦幅÷yNumで決まる
    /// - Returns: xNum * yNum個の分割されたUIImage
    func divImage(_ xNum: Int, yNum: Int)-> [UIImage]{
        let image = self
        let width = image.size.width / CGFloat(xNum)
        let height = image.size.height / CGFloat(yNum)
        var imgs: [UIImage] = []
        for y in 0..<yNum{
            for x in 0..<xNum{
                imgs.append(UIImage.clipImage(image, x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height))
            }
        }
        
        return imgs
    }
    
    /// 画像分割読み込み
    ///
    /// - Parameters:
    ///   - named: 画像名
    ///   - xNum: x方向に何個分割するか
    ///   - yNum: y方向に何個分割するか
    ///   - width: 分割される画像の横幅
    ///   - height: 分割される画像の縦幅
    /// - Returns: xNum * yNum個の分割されたUIImage
    public static func divImage(_ named: String, xNum: Int, yNum: Int, width: CGFloat, height: CGFloat)-> [UIImage]?{
        guard let image = UIImage(named: named) else{
            return nil
        }
        var imgs:[UIImage] = []
        for y in 0..<yNum{
            for x in 0..<xNum{
                imgs.append(clipImage(image, x: CGFloat(x) * width, y: CGFloat(y) * height, width: width, height: height))
            }
        }
        return imgs
    }
    
    private static func clipImage(_ image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat , height: CGFloat) -> UIImage {
        let imageRef = image.cgImage!.cropping(to: CGRect(x: x,y: y,width: width,height: height))
        let cropImage = UIImage(cgImage: imageRef!)
        return cropImage
    }
    
    /// 複数枚の画像を合成
    ///
    /// 画像の大きさはそれぞれの方向の最大値となる
    /// - Parameter UIImage: 背面からの順番の画像配列
    /// - Returns: 合成した画像
    public static func compose(_ from: [UIImage?])-> UIImage{
        let images = from.compactMap({ $0 })
        //それぞれの方向の最大サイズを取得
        let width = images.max{
            $0.size.width < $1.size.width
            }?.size.width ?? 0
        
        let height = images.max{
            $0.size.height < $1.size.height
            }?.size.height ?? 0
        
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        
        // UIImageのある分回す.
        for image : UIImage in images {
            // コンテキストに画像を描画する.
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    /// 指定サイズで単色で塗りつぶされた画像を生成
    ///
    /// - Parameters:
    ///   - color: 塗りつぶす色
    ///   - size: 画像サイズ
    /// - Returns: 画像
    public static func image(from color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 指定サイズでグラディエーションされた画像を生成
    ///
    /// - Parameters:
    ///   - gradients: グラディエーションする時の色
    ///   - size: 画像サイズ
    /// - Returns: 画像
    public static func image(from gradients: [UIColor], size: CGSize) -> UIImage {
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradients
        //グラデーションレイヤーをスクリーンサイズにする
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.frame = frame
        let view = UIView(frame: frame)
        view.layer.addSublayer(gradientLayer)
        return view.screenShot()
    }
    
    public func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

extension Dictionary {
    /// 二つのDictionaryを結合させる
    ///
    /// - Parameter other: 結合させるDictionary
    /// - Returns: 結合したDictionary
    public func union(_ other: Dictionary) -> Dictionary {
        var tmp = self
        other.forEach { tmp[$0.0] = $0.1 }
        return tmp
    }
}

extension CALayer{
    func layer(with name: String)-> CALayer?{
        var l: CALayer?
        sublayers?.forEach({
            if $0.name == name{
                l = $0
            }
        })
        return l
    }
}


/// Extension this protocol when you need enumerate or array of enum, number of enum.
///
/// However cannot be used for enum with Associated Value
public protocol EnumEnumerable {
    associatedtype Case = Self
}

public extension EnumEnumerable where Case: Hashable {
    private static var iterator: AnyIterator<Case> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Case.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }

    /// - Returns: enumerate of enum
    public static func enumerate() -> EnumeratedSequence<AnySequence<Case>> {
        return AnySequence(self.iterator).enumerated()
    }
    
    /// - Returns: array of enum
    public static var cases: [Case] {
        return Array(self.iterator)
    }
    
    /// - Returns: number of enum
    public static var count: Int {
        return self.cases.count
    }
}


