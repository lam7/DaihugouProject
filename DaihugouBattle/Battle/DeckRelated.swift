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
    
    init(deck: Deck, cards: [Card]){
        super.init(cards: cards, name: deck.name)
        if let id = (deck as? DeckRelated)?.objectId{
            self.objectId = id
        }
    }
    
    override init(cards: [Card], name: String) {
        super.init(cards: cards, name: name)
    }
}
