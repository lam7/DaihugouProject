//
//  Spot.swift
//  DaihugouBattle
//
//  Created by Main on 2017/10/05.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation

protocol SpotDelegate: class{
    ///Spotにカードが出されたタイミングで呼ばれる
    func didPutDown(_ cards: [Card], isOwner: Bool)
    ///Spotのカードを全て消すときに呼ばれる
    func removeAll(_ cards: [Card])
}

class Spot: NSCopying{
    private(set) var cardsWithIdentifer: [(cards: [Card], isOwner: Bool)] = []
    private(set) var table: Table
    weak var delegate: SpotDelegate?
    
    /// オーナー側が出したカード
    var ownerCards: [Card]{
        return cardsWithIdentifer.filter({ $0.isOwner }).map({ $0.cards }).reduce([], { $0 + $1 })
    }
    /// 敵側が出したカード
    var enemyCards: [Card]{
        return cardsWithIdentifer.filter({ !$0.isOwner }).map({ $0.cards }).reduce([], { $0 + $1 })
    }
    /// 場に出た全てのカード
    var allCards: [Card]{
        return cardsWithIdentifer.map({ $0.cards }).reduce([], { $0 + $1 })
    }
    
    init(table: Table){
        self.table = table
    }
    
    
    func canPutDown(_ cards: [Card])-> Bool{
        return table.canPutDown(cards, spotCards: self.allCards)
    }
    
    
    /// 場にカードを加える
    ///
    /// - Parameters:
    ///   - card: 加えるカード配列
    ///   - isOwner: オーナー側が出したカードかどうか
    func putDown(_ cards: [Card], isOwner: Bool){
        cardsWithIdentifer.append((cards, isOwner))
        delegate?.didPutDown(cards, isOwner: isOwner)
    }
    
    /// 場から全てのカードを取り除く
    @discardableResult func removeAll()-> [Card]{
        let cards = allCards
        cardsWithIdentifer.removeAll()
        delegate?.removeAll(cards)
        return cards
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let spot = Spot(table: self.table.copy() as! Table)
        spot.cardsWithIdentifer = cardsWithIdentifer
        spot.delegate = delegate
        return spot
    }
}
