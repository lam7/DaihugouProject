//
//  CAAnimationGroup+DurationAdjuster.swift
//  DaihugouBattle
//
//  Created by sakamoto kazuhiro on 2014/01/22.
//  Copyright (c) 2014年 soragoto. All rights reserved.
//  Github  https://github.com/kazu0620/CAAnimationGroup-DurationAdjuster
//
//  Editor: Main

import Foundation
import UIKit

extension CAAnimationGroup{
    /// アニメーションを連続で再生するようにパラメータを調節する
    func setDurationToSequentially(){
        var summedDuration: CFTimeInterval = 0
        guard let animations = animations else{
            return
        }
        for animation in animations{
            animation.isRemovedOnCompletion = false
            animation.fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
            animation.beginTime = summedDuration
            summedDuration += executeDurationWithAnimation(animation)
        }
        duration = summedDuration
    }
    
    
    
    /// 全てのアニメーションが同時に行われるようにパラメータを調節する
    func setDurationToSameTimeSpawn(){
        var maxDurationLength: CFTimeInterval = 0
        guard let animations = animations else{
            return
        }
        for animation in animations{
            animation.isRemovedOnCompletion = false
            animation.fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
            animation.beginTime = 0
            let executeDuration = executeDurationWithAnimation(animation)
            if maxDurationLength < executeDuration {
                maxDurationLength = executeDuration
            }
        }
        duration = maxDurationLength
        fillMode = convertToCAMediaTimingFillMode(convertFromCAMediaTimingFillMode(CAMediaTimingFillMode.forwards))
        isRemovedOnCompletion = false
    }
    
    private func executeDurationWithAnimation(_ animation: CAAnimation)-> CFTimeInterval{
        var executeDuration = animation.autoreverses ? animation.duration * 2 : animation.duration
        if animation.repeatCount != 0 {
            executeDuration *= animation.repeatCount.d
        }
        return executeDuration
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
