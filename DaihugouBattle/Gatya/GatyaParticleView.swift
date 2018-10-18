//
//  GatyaParticleView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/13.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class GatyaParticleView: UIView{
    weak var sceneView: SceneView!
    weak var scene: GatyaParticleScene!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp(){
        let sceneView = SceneView(frame: frame)
        let scene = GatyaParticleScene(size: bounds.size)
        scene.scaleMode = .aspectFit
        sceneView.presentScene(scene)
        addSubview(sceneView)
        self.sceneView = sceneView
        self.scene = scene
    }
}
