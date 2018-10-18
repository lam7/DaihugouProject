//
//  CollectionCardDetailView.swift
//  DaihugouBattle
//
//  Created by Main on 2017/11/14.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CollectionCardDetailView: CharacterDetailView{
    var card: Card!
    
    override func set(card: Card) {
        super.set(card: card)
        self.card = card
    }
    
    override func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        if imageView.frame.contains(location){
            self.parentViewController()?.performSegue(withIdentifier: "swipeable", sender: self.parentViewController())
        }else{
            super.tap(sender)
        }
    }
}
