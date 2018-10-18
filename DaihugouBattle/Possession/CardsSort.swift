//
//  CardsSort.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/07.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation

class CardsSort{
    typealias CardsSortBy = ((Card, Card) -> Bool)
    
    enum SortBy: Int{
        case id, atk, index, rarity, hp
    }
    static let atkSort: CardsSortBy = { $0.atk < $1.atk }
    static let indexSort: CardsSortBy = { $0.index < $1.index }
    static let idSort: CardsSortBy = { $0.id < $1.id }
    static let raritySort: CardsSortBy = { CardRarity.allCases.firstIndex(of: $0.rarity)! < CardRarity.allCases.firstIndex(of: $1.rarity)! }
    static let hpSort: CardsSortBy = { $0.hp < $1.hp }
    
    
    static func sort(_ cards:  [Card], by: SortBy, isAsc: Bool)-> [Card]{
        //SortByと同じ並びにすること
        let sorts = [idSort, atkSort, indexSort, raritySort, hpSort]
        let sort = sorts[by.rawValue]
        //isAckがfalseのとき結果をひっくり返すのはxnorと同値
        return cards.sorted(by: {
            sort($0, $1) == isAsc
        })
    }
}
