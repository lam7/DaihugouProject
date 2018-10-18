//
//  TouchParticleViewController.swift
//  DaihugouBattle
//
//  Created by Main on 2017/12/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SpriteKit

class TDPViewController: UIViewController{
    private(set) var particleScene: TouchDownParticleScene!
    private(set) var particleSKView: SKView!
    override func viewDidLoad() {
        super.viewDidLoad()
        particleSKView = SKView(frame: view.bounds)
        particleScene = TouchDownParticleScene(size: view.frame.size)
        particleScene.scaleMode = .aspectFit
        view.addSubview(particleSKView)
        particleSKView.presentScene(particleScene)
        particleSKView.ignoresSiblingOrder = true
        particleSKView.showsFPS = true
        particleSKView.showsNodeCount = true
        
    }
}
