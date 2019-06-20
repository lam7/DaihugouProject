//
//  SceneView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/02/01.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import SpriteKit

class SceneView: UIView{
    weak var scene: SKScene!
    weak var skView: SKView!
    
    override var frame: CGRect{
        didSet{
            if skView != nil{
                skView.frame = bounds
                scene.size = frame.size
            }
        }
    }
    
    func presentScene(_ scene: SKScene.Type){
        let skView = SKView(frame: bounds)
        let scene = scene.init(size: frame.size)
        addSubview(skView)
        skView.presentScene(scene)
        self.skView = skView
        self.scene = scene
        scene.backgroundColor = .clear
        skView.backgroundColor = .clear
        backgroundColor = .clear
        skView.allowsTransparency = true
    }
}
