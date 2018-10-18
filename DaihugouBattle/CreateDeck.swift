//
//  CreateDeck.swift
//  DaihugouBattle
//
//  Created by Main on 2017/09/20.
//  Copyright © 2017年 Main. All rights reserved.
//

import Foundation


/// デッキ作成Protocol
protocol CreateDeck {
    
    /// デッキ作成時にデッキに入れることが出来るカードの最大容量
    static var CountOfLimit: Int{get}
    /// デッキ枚数
    static var CountAtCompletion: Int{get}
    /// デッキのカード配列
    var deckCards: [Card]{get}
    /// デッキにカードを追加
    ///
    /// - Parameter card: 追加するカード
    /// - Throws: これ以上カードを追加できないときにCrossedDeckError.OverCountOfLimitを返す
    func append(_ card: Card) throws
    /// デッキからカードを削除
    ///
    /// - Parameter at: deckCards[at]のカードを削除する
    /// - Throws: 不明な位置にatがあるならCrossedDeckError.OutOfRangeを返す
    func remove(at: Int) throws
    
    /// デッキを作成する
    /// デッキをチェックしエラーが何もないならUserInfo.append(deck)を呼び出す
    /// - Parameter completion: デッキ追加完了後の処理
    func create(_ completion: @escaping (_ error: Error?) -> ())
}

enum CreateDeckError: Error{
    case InsufficientNumberOfCards
    case ExceedNumberOfCards
}

enum CrossedDeckError: Error{
    case OverCountOfLimit
    case OutOfRange
}

class CreateStandartDeck: CreateDeck{
    static var CountOfLimit: Int{
        return 50
    }
    
    static var CountAtCompletion: Int{
        return 40
    }
    
    private var cards: [Card]
    
    var deckCards: [Card]{
        return cards
    }
    
    init(){
        cards = []
    }
    
    func append(_ card: Card) throws{
        if cards.count >= CreateStandartDeck.CountOfLimit{
            throw CrossedDeckError.OverCountOfLimit
        }
        cards.append(card)
        
        cards.sort(by: {
            if $0.index == $1.index{
                return $0.id < $1.id
            }else{
                return $0.index < $1.index
            }
        })
    }
    
    func remove(at: Int) throws{
        if cards.inRange(at){
            cards.remove(at: at)
        }else{
            throw CrossedDeckError.OutOfRange
        }
    }
    
    func create(_ completion: @escaping (_ error: Error?) -> ()){
        let count = CreateStandartDeck.CountAtCompletion
        if cards.count > count{
            completion(CreateDeckError.ExceedNumberOfCards)
        }
        if cards.count < count{
            completion(CreateDeckError.InsufficientNumberOfCards)
        }
        
        UserInfo.append(cards: cards, completion: completion)
    }
}
