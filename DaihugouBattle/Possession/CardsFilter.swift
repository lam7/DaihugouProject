//
//  CardsFilter.swift
//  DaihugouBattle
//
//  Created by Main on 2018/04/23.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation

class CardsFilter{
    private typealias Check = ((Card) -> Bool)
    
    static func filter(_ cards: [Card], text: String)-> [Card]{
        if text == ""{ return  cards }
        let skill: Check = { !$0.skills.filter({ $0.description.contains(text) }).isEmpty }
        let name: Check  = {
            let string = $0.name.applyingTransform(.hiraganaToKatakana, reverse: true) ?? $0.name
            return string.contains(text)
        }
        return cards.filter{
            skill($0) || name($0)
        }
    }
    
    static func filter(_ cards: [Card], indexs: [Int])-> [Card]{
        if indexs.isEmpty{ return cards }
        let index: Check  = { indexs.contains($0.index) }
        return cards.filter{
            index($0)
        }
    }
    
    static func filter(_ cards: [Card], rarities: [CardRarity])-> [Card]{
        if rarities.isEmpty{ return cards }
        let rarities: Check  = { rarities.contains($0.rarity) }
        return cards.filter{
            rarities($0)
        }
    }
    
    static func filter(_ cards: [Card], indexs: [Int], rarities: [CardRarity], text: String)-> [Card]{
        var cards = filter(cards, text: text)
        cards     = filter(cards, indexs: indexs)
        cards     = filter(cards, rarities: rarities)
        return cards
    }
}
