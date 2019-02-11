//
//  TouchParticleScene.swift
//  DaihugouBattle
//
//  Created by Main on 2017/12/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SpriteKit

class TouchDownParticleScene: SKScene{
    let TouchBeganParticle = SKEmitterNode(fileNamed: "TouchBeganParticle.sks")!
    let TouchMovedParticle = SKEmitterNode(fileNamed: "TouchMovedParticle.sks")!
    var originalRaySpriteNode = SKSpriteNode(imageNamed: "ray.png")
    var originalCircleSpriteNode = SKSpriteNode(imageNamed: "circle.png")

    let RayColor: UIColor = .blue
    
    private let RayRadius: CGFloat = 20
    let MaxRayNumber = 10
    private weak var particleLayer: SKNode!
    private var touchMovedParticleBirthRate: CGFloat = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        initOriginalRay()
        initOriginalCircle()
        createParticleLayer()
        backgroundColor = .clear
        particleLayer.addChild(TouchMovedParticle)
        TouchMovedParticle.targetNode = particleLayer
        touchMovedParticleBirthRate = TouchMovedParticle.particleBirthRate
    }
    
    private func initOriginalRay(){
        originalRaySpriteNode.blendMode = .add
        originalRaySpriteNode.color = RayColor
        originalRaySpriteNode.alpha = 1
        originalRaySpriteNode.size = CGSize(width: 10, height: 2)
    }
    
    private func initOriginalCircle(){
        originalCircleSpriteNode.blendMode = .screen
        originalCircleSpriteNode.color = RayColor
        originalCircleSpriteNode.alpha = 1
        originalCircleSpriteNode.size = CGSize(width: 70, height: 70)
    }
    
    private func createParticleLayer(){
        let particleLayer = SKNode()
        addChild(particleLayer)
        self.particleLayer = particleLayer
    }
 
    func touchBeganAnimation(_ duration: TimeInterval, location: CGPoint, completion: @escaping () -> ()){

        let circleNode = createCircleSpriteNode()
        let emitter = TouchBeganParticle.copy() as! SKEmitterNode
        
        emitter.position = location
        circleNode.position = location
        particleLayer.addChild(circleNode)
        particleLayer.addChild(emitter)
        
        circleAnimation(circleNode, duration: 0.2, completion: {})
        let action = SKAction.wait(forDuration: TimeInterval(emitter.particleLifetime))
        emitter.run(action, completion: {
            emitter.removeFromParent()
//
//            emitter.particleBirthRate = 0
//            emitter.run(SKAction.wait(forDuration: TimeInterval(1))){
//            }
            completion()
        })
    }
    
    func createRaySpriteNodes(_ count: Int)-> [SKSpriteNode]{
        var rays: [SKSpriteNode] = []
        for _ in 0..<count{
            rays.append(originalRaySpriteNode.copy() as! SKSpriteNode)
        }
        return rays
    }
    
    func createCircleSpriteNode()-> SKSpriteNode{
        return originalCircleSpriteNode.copy() as! SKSpriteNode
    }
    
    func rayAnimation(_ raySpriteNodes: [SKSpriteNode], duration: TimeInterval, completion: @escaping () -> ()){
        for (i, sprite) in raySpriteNodes.enumerated(){
            let di: CGFloat = i.cf / MaxRayNumber
            let angle: CGFloat = CGFloat.pi * 2.0 * di
            sprite.zRotation = angle
            let action = createRayAction(sprite.position, angle: angle)
            action.duration = duration
            sprite.run(action){
                sprite.removeFromParent()
                if i == raySpriteNodes.count - 1{
                    completion()
                }
            }
        }
    }
    
    func createRayAction(_ center: CGPoint, angle: CGFloat)-> SKAction{
        let dx: CGFloat = RayRadius * cos(angle)
        let dy: CGFloat = RayRadius * sin(angle)
        let moveToX: CGFloat = center.x + dx
        let moveToY: CGFloat = center.y + dy
        let moveTo: CGPoint  = CGPoint(x: moveToX, y: moveToY)
        return SKAction.move(to: moveTo, duration: 1.0)
    }
    
    func circleAnimation(_ circleSpriteNode: SKSpriteNode, duration: TimeInterval, completion: @escaping () -> ()){
        let scale: CGFloat = 1.1
        let action1 = SKAction.scale(by: scale, duration: duration)
        let action2 = SKAction.fadeAlpha(to: 0.1, duration: duration)
        let action = SKAction.group([action1, action2])
        circleSpriteNode.run(action, completion: {
            circleSpriteNode.removeFromParent()
            completion()
        })
    }

    func touchesBegan(_ location: CGPoint) {
        let l = CGPoint(x: location.x, y: frame.height - location.y)
        touchBeganAnimation(0.8, location: l, completion: {})
        TouchMovedParticle.particleBirthRate = touchMovedParticleBirthRate
        TouchMovedParticle.position = l
    }
    
    func touchesMoved(_ location: CGPoint) {
        let l = CGPoint(x: location.x, y: frame.height - location.y)
        TouchMovedParticle.position = l
    }
    
    func touchesEnded(_ location: CGPoint) {
        TouchMovedParticle.particleBirthRate = 0
    }
    
    func touchesCancelled(_ location: CGPoint) {
        TouchMovedParticle.particleBirthRate = 0
    }
    
}
