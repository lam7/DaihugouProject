//
//  AudioVolumeSettingView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/04.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit

//
//  SettingSelectViewHome.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/04.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class AudioVolumeSettingView: UINibView, BlockableOutsideTouchView {
    
    private weak var windowView: UIView!
    weak var behindView: UIView?
    
    
    override func didMoveToSuperview() {
        behindView = setUpBehindView()
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(AudioVolumeSettingView.tapBehind(_:)))
        behindView?.addGestureRecognizer(tapGesure)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil{
            behindView?.removeSafelyFromSuperview()
        }
    }
    
    @objc func tapBehind(_ sender: UITapGestureRecognizer){
        removeSafelyFromSuperview()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }
    
    private func setUp(){
        let bgm = viewWithTag(1) as! UISlider
        let se = viewWithTag(2) as! UISlider
        bgm.value = ManageAudio.shared.bgmVolume
        se.value = ManageAudio.shared.seVolume
        let windowView = UIView(frame: .zero)
        insertSubview(windowView, at: 0)
        self.windowView = windowView
    }
    
    
    @IBAction func valueChanged(_ sender: UISlider){
        switch sender.tag{
        case 1:
            ManageAudio.shared.bgmVolume = sender.value
        case 2:
            ManageAudio.shared.seVolume = sender.value
        default:
            break
        }
    }
    
    @IBAction func touchUp(_ sender: UIButton){
        removeFromSuperview()
    }
    
    override func removeFromSuperview() {
        UIView.animateCloseWindow(self){
            super.removeFromSuperview()
        }
    }
}

