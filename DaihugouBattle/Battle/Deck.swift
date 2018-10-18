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
        return Deck(cards: cards, name: "NoDataDeck")
    }
    
    /// デッキ
    private(set) var cards: [Card]
    private(set) var name: String
    
    init(cards: [Card], name: String){
        self.cards = cards
        self.name = name
    }
    
    final func notExistDeckCards(in possessionCards: CardCount)-> CardCount{
        var possessionCards = possessionCards
        var notExistCards: CardCount = [:]
        
        for card in cards.reversed(){
            if possessionCards[card] != nil && possessionCards[card]! >= 1{
                possessionCards -= card
            }else{
                notExistCards += card
            }
        }
        return notExistCards
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Deck(cards: cards.map{ $0.copy() as! Card }, name: name)
    }
}
