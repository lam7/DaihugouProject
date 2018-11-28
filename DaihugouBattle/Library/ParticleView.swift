//
//  ParticleView.swift
//  DaihugouBattle
//
//  Created by Main on 2018/01/31.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation
import SpriteKit

class ParticleView: UIView{
    private(set) weak var sceneView: SceneView!
    private(set) var particles: [SKEmitterNode] = []
    private var particlesBirthRate: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    private func setUp(){
        let sceneView = SceneView(frame: bounds)
        addSubview(sceneView)
        self.sceneView = sceneView
        sceneView.presentScene(SKScene(size: frame.size))
    }
    
    func presentParticles(_ filesNamed: String...){
        for fileNamed in filesNamed{
            guard let particle = SKEmitterNode(fileNamed: fileNamed) else{
                print("Dismiss particle fileNamed")
                continue
            }
            particle.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
            particles.append(particle)
        }
    }
    
    func presentParticles(_ filesNamed: [String]){
        for fileNamed in filesNamed{
            guard let particle = SKEmitterNode(fileNamed: fileNamed) else{
                print("Dismiss particle fileNamed")
                continue
            }
            particle.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
            particles.append(particle)
        }
    }
    
    func fire(){
        for particle in particles{
            if particle.parent != nil{ continue }
            sceneView.scene.addChild(particle)
        }
    }
    
    func fire(_ duration: TimeInterval, completion: @escaping () -> ()){
        for particle in particles{
            if particle.parent != nil{ continue }
            sceneView.scene.addChild(particle)
            particle.run(SKAction.wait(forDuration: duration)){
                particle.removeFromParent()
                if particle == self.particles.last{ completion() }
            }
        }
    }
    
    func setParticles(point: CGPoint){
        for particle in particles{
            particle.position = point
        }
    }

    func pause(){
        particlesBirthRate = []
        for particle in particles{
            particlesBirthRate.append(particle.particleBirthRate)
            particle.particleBirthRate = 0
        }
    }
    
    func resume(){
        for (i, particle) in particles.enumerated(){
            particle.particleBirthRate = particlesBirthRate[i]
        }
        particlesBirthRate = []
    }
}
