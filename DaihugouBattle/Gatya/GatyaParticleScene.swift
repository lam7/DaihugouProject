//
//  ParticleScene.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/26.
//  Copyright © 2017年 Main. All rights reserved.
//


import Foundation
import AVFoundation
import SpriteKit
import Chameleon

class GatyaParticleScene: SKScene{
    ///演出のためのパーティクルのオリジナル
    private let particleOriginal = SKEmitterNode(fileNamed: "GatyaParticle.sks")!
    private let packParticleOriginal = SKEmitterNode(fileNamed: "GatyaPackParticle.sks")!
    private let packNormalParticleOriginal = SKEmitterNode(fileNamed: "GatyaPackParticle1.sks")!
    private weak var packNormalParticle: SKEmitterNode?
    private var packNormalParticleBirthRate: CGFloat = 0
    
    func perform(_ delay: TimeInterval = 0.0, card: Card, view: UIView, completion: @escaping () -> ()){
        let particle = particleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        let colors: [UIColor] = [.flatPurple(), .flatYellow(), .flatWhite(), .flatRed()]
        let index = CardRarity.allCases.firstIndex(of: card.rarity)!
        particle.particleColor = colors[index]
        particle.particleColorBlendFactor = 1
        particle.particleColorSequence = nil
        let presentation = view.layer.presentation()!
        particle.position = CGPoint(x: presentation.position.x, y: self.size.height - presentation.position.y)
        
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false){_ in
            self.addChild(particle)
            particle.isHidden = false
            let duration = TimeInterval(self.particleOriginal.particleLifetime)
            particle.run(SKAction.wait(forDuration: duration)){
                particle.removeFromParent()
                completion()
            }
        }.fire()
    }
    
    func perform(_ delay: TimeInterval = 0.0, pack: UIView, completion: @escaping () -> ()){
        let particle = packParticleOriginal.copy() as! SKEmitterNode
        particle.setScale(0.8)
        particle.position = CGPoint(x: pack.center.x, y: self.size.height - pack.center.y)
        
        
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false){_ in
            self.addChild(particle)
            particle.isHidden = false
            let duration = TimeInterval(self.packParticleOriginal.particleLifetime)
            particle.run(SKAction.wait(forDuration: duration)){
                particle.removeFromParent()
                completion()
            }
            }.fire()
    }
    
    func setUpNormalParticle(){
        let particle = packNormalParticleOriginal.copy() as! SKEmitterNode
        particle.particlePositionRange.dx = frame.width
        particle.particlePositionRange.dy = frame.height
        let point = CGPoint(x: frame.midX, y: frame.midY)
        particle.position = point
        packNormalParticleBirthRate = particle.particleBirthRate
        addChild(particle)
        packNormalParticle = particle
    }
    
    func playNormal(){
        guard let packNormalParticle = packNormalParticle else{
            return
        }
        packNormalParticle.particleBirthRate = packNormalParticleBirthRate
    }
    
    func stopNormal(){
        guard let packNormalParticle = packNormalParticle else{
            return
        }
        packNormalParticle.particleBirthRate = 0
    }
}



