//
//  BattleDeck.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/16.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation

class DeckBattle{
    private var deck: Deck
    private var cards: [Card]
    private var originalCards: [Card]{ return deck.cards }
    
    init(deck: Deck){
        let cards = deck.cards.map({ CardBattle(card: $0) })
        self.cards = cards
        self.deck = deck
    }
    
    /// デッキの指定位置にあるカードを引く
    /// 引いたカードはデッキから消える
    /// - at: インデックス
    /// - Returns: 引いたカード　指定位置にカードがないならnil
    private func getCard(at: Int)-> Card?{
        return cards.remove(safe: at)
    }
    
    /// デッキの一番上にあるカードを引く
    /// 引いたカードはデッキから消える
    ///
    /// - Returns: 引いたカード　デッキが空ならnil
    private func getCardAtFirst()-> Card?{
        return getCard(at: 0)
    }
    
    func drawCards(_ amount: Int = 1)-> [Card?]{
        return (0..<amount).map{ _ in getCardAtFirst() }
    }
    
    func shuffle(){
        cards.shuffle()
    }
}
