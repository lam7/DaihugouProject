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
        sceneView.presentScene(GatyaParticleScene.self)
        addSubview(sceneView)
        self.sceneView = sceneView
        scene = sceneView.scene as! GatyaParticleScene
        scene.scaleMode = .aspectFit
    }
}
