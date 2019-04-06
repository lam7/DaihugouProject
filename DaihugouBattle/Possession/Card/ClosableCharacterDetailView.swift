//
//  ClosableCharacterDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/14.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit


protocol Closable{
    var close: (()->())?{ get set }
}

@IBDesignable class ClosableCharacterDetailView: UINibView, Closable{
    var card: Card!{
        didSet{
            characterDetailView.set(card: card)
        }
    }
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    @IBOutlet weak var closeButton: UIButton!
    var close: (()->())?
    @IBAction func touchUp(_ sender: UIButton){
        close?()
    }
}
