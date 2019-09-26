//
//  Deck.swift
//  Daihugou
//
//  Created by Main on 2017/06/05.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

class Deck: NSCopying{
    static func noDataDeck(_ numOfDeckCards: Int, type: Card.Type)-> Deck{
        let cards = (0..<numOfDeckCards).map({ _ in type.init(card: cardNoData) })
        return Deck(cards: cards)
    }
    
    /// デッキ
    private(set) var cards: [Card]
    
    init(cards: [Card]){
        self.cards = cards
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Deck(cards: cards.map{ $0.copy() as! Card })
    }
}
