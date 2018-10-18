//
//  PossessionCardDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/14.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PossessionCardDetailView: UINibView{
    var card: Card!{
        didSet{
            characterDetailView.set(card: card)
        }
    }
    var delegate: ((_: PossessionCardDetailView)->())?
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return superview!.point(inside: point, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else{
            return
        }
        if !frame.contains(point){
            touch()
        }
    }
    
//    func set(card: Card) {
//        characterDetailView.set(card: card)
//        self.card = card
//    }
    
    @IBAction func touchUp(_ sender: UIButton){
        touch()
    }
    
    func touch(){
        if let delegate = delegate{
            delegate(self)
            return
        }
        isHidden = true
    }
}
