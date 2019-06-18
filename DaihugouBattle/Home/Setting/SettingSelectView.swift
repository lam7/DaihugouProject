//
//  SettingSelectView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/04.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
@IBDesignable class SettingSelectView: UINibView, SelectableView {
    weak var displayView: UIView?{
        didSet{
            oldValue?.removeSafelyFromSuperview()
        }
    }

    @IBAction func touchUp(_ sender: UIButton) {
        ManageAudio.shared.play("click.mp3")
        buttonTransition(sender)
        switch sender.tag{
        case 1:
            let dx: CGFloat = 10
            let dy: CGFloat = 10
            let audioFrame = CGRect(x: dx, y: dy, width: self.frame.width - dx * 2, height: self.frame.height - dy * 2)
            let audioView = AudioVolumeSettingView(frame: audioFrame)
            OuterFrameClosableView.show(audioView)
            self.addSubview(audioView)
            UIView.animateOpenWindow(audioView)
            self.displayView = audioView
        case 2:
            let parent = self.parentViewController()
            parent?.performSegue(withIdentifier: "main", sender: parent)
        case 3:
            let width = self.frame.width * 0.8
            let height = self.frame.height * 0.3
            let nameFrame = CGRect(x: self.center.x - width / 2, y: 50, width: width, height: height)
            let nameView = PlayerNameSettingView(frame: nameFrame)
            OuterFrameClosableView.show(nameView)
            self.addSubview(nameView)
            UIView.animateOpenWindow(nameView)
            self.displayView = nameView
        case 4:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "test") as! TestViewController
            self.parentViewController()?.present(mainVC, animated: true, completion: nil)
        default:
            break
        }
        
    }
}

func buttonTransition(_ with: UIButton, duration: TimeInterval = 0.3, options: UIView.AnimationOptions = UIView.AnimationOptions.transitionFlipFromRight, completion: ((_:Bool) -> ())? = nil){
    UIView.transition(with: with, duration: duration, options: options, animations: nil, completion: completion)
}
