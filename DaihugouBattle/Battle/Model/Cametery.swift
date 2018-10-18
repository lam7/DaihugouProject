//
//  Cametery.swift
//  DaihugouBattle
//
//  Created by Main on 2018/05/09.
//  Copyright © 2018年 Main. All rights reserved.
//

import Foundation


class Cametery{
    private(set) var cards: [Card] = []
    
    
    func append(_ card: Card){
        cards.append(card)
    }
    
    func append(_ cards: [Card]){
        self.cards += cards
    }
    
    func pop(_ card: Card)-> Card?{
        guard let index = cards.index(of: card) else{
            return nil
        }
        
        return cards.remove(at: index)
    }
    
    
}
