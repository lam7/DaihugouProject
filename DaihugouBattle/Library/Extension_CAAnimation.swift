//
//  Extension_CAAnimation.swift
//  DaihugouBattle
//
//  Created by Main on 2018/03/14.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


extension CAAnimationGroup{
    convenience init(animations: [CAAnimation]){
        self.init()
        self.animations = animations
    }
}
extension CAAnimation{
    fileprivate func setValuesNoRemoved(){
        isRemovedOnCompletion = false
        fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
    }
}

extension CABasicAnimation{
    static func move(_ duration: TimeInterval, by point: CGPoint)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        animation.byValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func move(_ duration: TimeInterval, to point: CGPoint)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position")
        animation.toValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        
        return animation
    }
    
    static func moveX(_ duration: TimeInterval, by point: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.byValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func moveX(_ duration: TimeInterval, to point: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.toValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func moveY(_ duration: TimeInterval, by point: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.byValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func moveY(_ duration: TimeInterval, to point: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.toValue = point
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    
    static func hidden(_ duration: TimeInterval, to isHidden: Bool)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.isHidden))
        animation.toValue = isHidden
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func rotateZ(_ duration: TimeInterval, to angle: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = angle
        animation.duration = duration
        animation.isCumulative = true
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func rotateZ(_ duration: TimeInterval, by angle: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.byValue = angle
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func scale(_ duration: TimeInterval, to ratio: CGFloat)-> CABasicAnimation{
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = ratio
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
    
    static func scale(_ duration: TimeInterval, to size: CGSize)-> CAAnimation{
        let width = CABasicAnimation(keyPath: "bounds.size.width")
        width.toValue = size.width
        width.duration = duration
        width.setValuesNoRemoved()
        let height = CABasicAnimation(keyPath: "bounds.size.height")
        height.toValue = size.height
        height.duration = duration
        height.setValuesNoRemoved()
        let group = CAAnimationGroup(animations: [width, height])
        group.setDurationToSameTimeSpawn()
        return group
    }
}

extension CAKeyframeAnimation{
    static func move(_ duration: TimeInterval, by path: UIBezierPath)-> CAKeyframeAnimation{
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.path = path.cgPath
        animation.duration = duration
        animation.setValuesNoRemoved()
        return animation
    }
}

class CAAnimationCompletion<T: CAAnimationDelegate>{
    private(set) var completionBlock: [((_: Bool, _: Any?) -> ())?] = []
    let BlockKey: String = "animationId"
    private let BlockValuesKey: String = "animationValues"
    private var parent: T
    
    
    /// CAAnimationDelegateを実装したクラスでのみ使用できる
    ///
    /// - Required: CAAnimationDelegate.animationDidStopでこのクラスのanimationDidStopよ呼ぶこと
    /// - Parameter parent: 基本的にself
    init(parent: T){
        self.parent = parent
    }
    
    func animationDidStop(_ anim: CAAnimation, finished: Bool){
        guard let id = anim.value(forKey: BlockKey) as? Int,
            let block = completionBlock[safe: id] else{
                return
        }
        let values = anim.value(forKey: BlockValuesKey)
        block?(finished, values)
        completionBlock[id] = nil
        anim.setValue(nil, forKey: BlockValuesKey)
        anim.setValue(nil, forKey: BlockKey)
    }
    
    func add(_ anim: CAAnimation, completion: @escaping () -> ()){
        anim.setValue(completionBlock.count, forKey: BlockKey)
        anim.delegate = parent
        completionBlock.append({
            _, _ in
            completion()
        })
    }
    
    func add(_ anim: CAAnimation, completion: @escaping (_ finished: Bool) -> ()){
        anim.setValue(completionBlock.count, forKey: BlockKey)
        anim.delegate = parent
        completionBlock.append({
            flag, _ in
            completion(flag)
        })
    }
    
    
    func add(_ anim: CAAnimation, completion: @escaping (_ values: Any?) -> (), values: Any?){
        anim.setValue(completionBlock.count, forKey: BlockKey)
        anim.setValue(values, forKey: BlockValuesKey)
        anim.delegate = parent
        completionBlock.append({
            _, values in
            completion(values)
        })
    }
    
    func add(_ anim: CAAnimation, completion: @escaping (_ finished: Bool, _ values: Any?) -> (), values: Any?){
        anim.setValue(completionBlock.count, forKey: BlockKey)
        anim.setValue(values, forKey: BlockValuesKey)
        anim.delegate = parent
        completionBlock.append({
            flag, values in
            completion(flag, values)
        })
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFillMode(_ input: String) -> CAMediaTimingFillMode {
	return CAMediaTimingFillMode(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFillMode(_ input: CAMediaTimingFillMode) -> String {
	return input.rawValue
}
