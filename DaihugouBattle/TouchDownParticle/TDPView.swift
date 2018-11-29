//
//  TDPView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/12/04.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import SpriteKit

class TDPView: UIView{
    static var shared: TDPView = TDPView()
    weak var sceneView: SceneView!
    
    override var frame: CGRect{
        didSet{
            if sceneView != nil{
                sceneView.frame = bounds
            }
        }
    }
    
    var tdpScene: TouchDownParticleScene{
        return sceneView.scene as! TouchDownParticleScene
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()

    }
    
    private func setUp(){
        self.isUserInteractionEnabled = false
        let sceneView = SceneView(frame: bounds)
        sceneView.presentScene(TouchDownParticleScene.self)
        addSubview(sceneView)
        self.sceneView = sceneView
        tdpScene.scaleMode = .aspectFill
        backgroundColor = .clear
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else{
            return
        }
        tdpScene.touchesBegan(location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else{
            return
        }
        tdpScene.touchesMoved(location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else{
            return
        }
        tdpScene.touchesEnded(location)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else{
            return
        }
        tdpScene.touchesCancelled(location)
    }
}
