//
//  GifEffectScene.swift
//  DaihugouBattle
//
//  Created by main on 2018/11/28.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import SpriteKit

class GifEffectScene: SKScene{
    var gifNodes: [GifEffectNode] = []

    func createNode(gif data: Data, position: CGPoint){
        
        let node = GifEffectNode(gif: data)
        node.position = position
        node.color = .clear
        
        addChild(node)
        gifNodes.append(node)
    }
    
    func startGif(){
        gifNodes.forEach({
            $0.startGif()
        })
    }
}

class GifEffectNode: SKSpriteNode{
    var textures: [SKTexture] = []
    var isPlaying: Bool = false

    init(gif data: Data){
        super.init(texture: nil, color: UIColor.init(red: 1, green: 1, blue: 1, alpha: 1), size: .zero)
        prepare(gif: data)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(gif data: Data){
        guard let cgImages = convertCGImages(data) else{
            print("Not gif data.")
            return
        }
        blendMode = .add

        let textures = cgImages.map({ SKTexture(cgImage: $0) })
        self.textures = textures
        textures.forEach({
            $0.filteringMode = SKTextureFilteringMode.linear
        })
        let texture = textures.first!
        
        self.size = texture.size()
    }
    
    func convertCGImages(_ data: Data)-> [CGImage]?{
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else{
            return nil
        }
        
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        
        for i in 0..<count {
            guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else{
                return nil
            }
            images.append(image)
        }
        
        return images
    }
    
    func actionGif(_ timePerFrame: TimeInterval)-> SKAction{
        return SKAction.animate(with: textures, timePerFrame: timePerFrame, resize: false, restore: true)
    }
    
    func startGif(_ timePerFrame: TimeInterval = 0.1, repeat: Int = 1, completion: (() -> ())? = nil){
        var action = actionGif(timePerFrame)
        action = SKAction.repeat(action, count: 1)
        self.isPlaying = true
        run(action, completion: {
            self.isPlaying = false
            completion?()
        })
    }
    
    
}
