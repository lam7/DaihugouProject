//
//  DeckRelated.swift
//  DaihugouBattle
//
//  Created by main on 2018/10/14.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation


class DeckRelated: Deck{
    lazy var objectId: String? = nil
    var name: String = ""
    
    init(deck: Deck, cards: [Card]){
        super.init(cards: cards)
        guard let deck = deck as? DeckRelated else{
            return
        }
        self.objectId = deck.objectId
        self.name = deck.name
    }
    
    override init(cards: [Card]) {
        super.init(cards: cards)
    }
}
