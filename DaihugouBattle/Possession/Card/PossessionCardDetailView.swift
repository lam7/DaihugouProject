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
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    @IBOutlet weak var cloesButton: UIButton!
    var tappedClose: (()->())?
    @IBAction func touchUp(_ sender: UIButton){
        tappedClose?()
    }
}
