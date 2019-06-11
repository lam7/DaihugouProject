//
//  ClosableCharacterDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/14.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ClosableCharacterDetailView: UINibView, ClosableView{
    var closeAction: (() -> ())?
    
    var card: Card!{
        didSet{
            characterDetailView.set(card: card)
        }
    }
    @IBOutlet weak var characterDetailView: CharacterDetailView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func touchUp(_ sender: UIButton){
        let closeAction = self.closeAction ?? self.closeView
        closeAction()
    }
}
